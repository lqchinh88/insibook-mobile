import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../models/books_screen_config.dart';
import '../utils/result.dart';
import '../providers/book_api_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/half_screen_book_card.dart';

class PaginatedBooksScreen extends StatefulWidget {
  final BooksScreenConfig config;

  const PaginatedBooksScreen({
    super.key,
    required this.config,
  });

  @override
  State<PaginatedBooksScreen> createState() => _PaginatedBooksScreenState();
}

class _PaginatedBooksScreenState extends State<PaginatedBooksScreen> {
  final List<InternalBookItem> _books = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _offset = 0;
  late final BookApiService _bookApiService;

  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;

    // Validate configuration
    if (!widget.config.isValid()) {
      setState(() {
        _errorMessage = 'Invalid screen configuration';
      });
      return;
    }

    _loadBooks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBooks();
    }
  }

  Future<void> _loadBooks({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _books.clear();
        _offset = 0;
        _hasMore = true;
      }
      _errorMessage = null;
    });

    final result = await _callApi();

    if (mounted) {
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
  }

  Future<void> _loadMoreBooks() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final result = await _callApi();

    if (mounted) {
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
  }

  /// Generic API calling based on configuration
  Future<ApiResult<InternalBookSearchResponse>> _callApi() {
    switch (widget.config.source) {
      case BooksDataSource.latest:
        return _bookApiService.getLatestBooks(
          limit: _limit,
          offset: _offset,
          sortBy: widget.config.effectiveSortBy,
          sortDirection: widget.config.effectiveSortDirection,
        );

      case BooksDataSource.category:
        return _bookApiService.getBooksByCategory(
          categoryId: widget.config.categoryId!,
          limit: _limit,
          offset: _offset,
          sortBy: widget.config.effectiveSortBy,
          sortDirection: widget.config.effectiveSortDirection,
        );

      case BooksDataSource.collection:
        return _bookApiService.getBooksByCollection(
          collectionId: widget.config.collectionId!,
          limit: _limit,
          offset: _offset,
          sortBy: widget.config.effectiveSortBy,
          sortDirection: widget.config.effectiveSortDirection,
        );

      case BooksDataSource.custom:
        return _bookApiService.getCustomSectionBooks(
          endpoint: widget.config.customEndpoint!,
          parameters: widget.config.customParameters,
          sortBy: widget.config.effectiveSortBy,
          sortDirection: widget.config.effectiveSortDirection,
          limit: _limit,
          offset: _offset,
        );
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(widget.config.title),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildBookGrid() {
    if (_isLoading && _books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadBooks(isRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBooks(isRefresh: true),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildAppBar(),
      ),
      body: _buildBookGrid(),
    );
  }
}