import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_service.dart';
import '../widgets/book_card.dart';
import 'book_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InternalBookItem> _latestBooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Pagination variables
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadLatestBooks();
  }

  Future<void> _loadLatestBooks({bool isLoadMore = false}) async {
    if (_isLoading || _isLoadingMore || (!_hasMore && isLoadMore)) return;

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _errorMessage = null;
        _offset = 0;
      }
    });

    try {
      final response = await BookApiService.getLatestBooks(
        limit: _limit,
        offset: isLoadMore ? _offset : 0,
      );

      if (response != null) {
        setState(() {
          if (isLoadMore) {
            _latestBooks.addAll(response.books);
            _offset += response.count;
          } else {
            _latestBooks = response.books;
            _offset = response.count;
          }
          _hasMore = response.count == _limit;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load latest books';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text('InsiBook'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookSearchScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLatestBooksSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadLatestBooks(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_latestBooks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No books found',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Latest Books',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _latestBooks.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _latestBooks.length) {
              if (_isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _loadLatestBooks(isLoadMore: true),
                    child: const Text('Load More'),
                  ),
                );
              }
            }
            return InternalBookCard(book: _latestBooks[index]);
          },
        ),
      ],
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
        onRefresh: () => _loadLatestBooks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _buildLatestBooksSection(),
        ),
      ),
    );
  }
}