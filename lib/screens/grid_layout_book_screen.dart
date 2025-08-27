import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../utils/result.dart';
import '../providers/book_api_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/half_screen_book_card.dart';

class GridLayoutBookScreen extends StatefulWidget {
  final String title;
  final String category;

  const GridLayoutBookScreen({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<GridLayoutBookScreen> createState() => _GridLayoutBookScreenState();
}

class _GridLayoutBookScreenState extends State<GridLayoutBookScreen> {
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

    // For now, only supporting "latest" category
    // In the future, you can add more categories here
    final result = await _bookApiService.getLatestBooks(
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
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    if (widget.category == 'latest') {
      final result = await _bookApiService.getLatestBooks(
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
    } else {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(widget.title),
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
      return const Center(
        child: Text(
          'No books found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildAppBar(),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadBooks(isRefresh: true),
        child: _buildBookGrid(),
      ),
    );
  }
}
