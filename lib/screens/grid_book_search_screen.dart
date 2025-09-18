import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../utils/result.dart';
import '../providers/book_api_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/half_screen_book_card.dart';
import '../widgets/star_rating_filter.dart';
import '../providers/language_provider.dart';

class GridBookSearchScreen extends StatefulWidget {
  final String title;
  final List<String>? categoryIds;
  final String? initialTitle;
  final String? initialAuthor;

  const GridBookSearchScreen({
    super.key,
    required this.title,
    this.categoryIds,
    this.initialTitle,
    this.initialAuthor,
  });

  @override
  State<GridBookSearchScreen> createState() => _GridBookSearchScreenState();
}

class _GridBookSearchScreenState extends State<GridBookSearchScreen> {
  final List<InternalBookItem> _books = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasSearched = false;
  bool _showSearchForm = false;
  double? _selectedStarRating;
  String? _errorMessage;
  int _offset = 0;
  late final BookApiService _bookApiService;

  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;

    // Initialize with provided values
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialAuthor != null) {
      _authorController.text = widget.initialAuthor!;
    }

    // Auto-search if category or initial values provided
    if (widget.categoryIds != null ||
        widget.initialTitle != null ||
        widget.initialAuthor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchBooks();
      });
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBooks();
    }
  }

  Future<void> _searchBooks({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _books.clear();
        _offset = 0;
        _hasMore = true;
      }
      _errorMessage = null;
      _hasSearched = true;
    });

    final result = await _bookApiService.searchInternalBooks(
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      author: _authorController.text.isNotEmpty ? _authorController.text : null,
      categoryIds: widget.categoryIds,
      minStarRating: _selectedStarRating,
      limit: _limit,
      offset: isRefresh ? 0 : _offset,
    );

    result.fold(
      (response) {
        setState(() {
          if (isRefresh) {
            _books.clear();
          }
          _books.addAll(response.books);
          _offset += response.count;
          _hasMore = response.count == _limit;
          _isLoading = false;
        });
      },
      (error) {
        setState(() {
          _errorMessage = error.userFriendlyMessage;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadMoreBooks() async {
    if (_isLoadingMore || !_hasMore || !_hasSearched) return;

    setState(() {
      _isLoadingMore = true;
    });

    final result = await _bookApiService.searchInternalBooks(
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      author: _authorController.text.isNotEmpty ? _authorController.text : null,
      categoryIds: widget.categoryIds,
      minStarRating: _selectedStarRating,
      limit: _limit,
      offset: _offset,
    );

    result.fold(
      (response) {
        setState(() {
          _books.addAll(response.books);
          _offset += response.count;
          _hasMore = response.count == _limit;
          _isLoadingMore = false;
        });
      },
      (error) {
        setState(() {
          _isLoadingMore = false;
        });
      },
    );
  }

  Widget _buildSearchForm() {
    final l10n = context.watch<LanguageProvider>().l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: l10n['book_title_search'] ?? 'Search for books you need',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.book),
            ),
            onSubmitted: (_) => _searchBooks(isRefresh: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              labelText: l10n['author_optional_search'] ?? 'Author (optional)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            onSubmitted: (_) => _searchBooks(isRefresh: true),
          ),
          const SizedBox(height: 16),
          StarRatingFilter(
            selectedRating: _selectedStarRating,
            onRatingChanged: (rating) {
              setState(() {
                _selectedStarRating = rating;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _searchBooks(isRefresh: true),
              child: Text(l10n['search_button'] ?? 'Search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    if (_isLoading && _books.isEmpty) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _books.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _searchBooks(isRefresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty && _hasSearched) {
      final l10n = context.watch<LanguageProvider>().l10n;
      return Expanded(
        child: Center(
          child: Text(
            l10n['no_books_found'] ?? 'No books found',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    if (_books.isEmpty && !_hasSearched) {
      final l10n = context.watch<LanguageProvider>().l10n;
      return Expanded(
        child: Center(
          child: Text(
            l10n['please_enter_search'] ?? 'Please enter a title or author to search',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => _searchBooks(isRefresh: true),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
          ),
          itemCount: _books.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _books.length) {
              return const Center(child: CircularProgressIndicator());
            }

            return HalfScreenBookCard(book: _books[index]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showSearchForm ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showSearchForm = !_showSearchForm;
              });
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0.0, -1.0), end: Offset.zero),
                ),
                child: child,
              );
            },
            child: _showSearchForm
                ? _buildSearchForm()
                : const SizedBox.shrink(),
          ),
          _buildBookGrid(),
        ],
      ),
    );
  }
}