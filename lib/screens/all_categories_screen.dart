import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../models/books_screen_config.dart';
import '../models/paginated_categories_response.dart';
import '../services/book_api_service.dart';
import '../providers/book_api_provider.dart';
import '../utils/result.dart';
import '../widgets/category_card.dart';
import 'paginated_books_screen.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  late final BookApiService _bookApiService;
  List<BookCategory> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _loadCategories();
  }

  Future<void> _loadCategories({bool isRefresh = false}) async {
    if (_isLoading && !isRefresh) return;

    if (isRefresh) {
      setState(() {
        _currentPage = 0;
        _hasMore = true;
        _categories.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _bookApiService.getAllCategories(
        offset: _currentPage * _pageSize,
        limit: _pageSize,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;

          if (result.isSuccess && result.value != null) {
            final response = result.value!;
            print('📊 Loaded categories: ${response.categories.length}, hasMore: ${response.hasMore}, total: ${response.totalCount}');
            _categories.addAll(response.categories);
            _hasMore = response.hasMore;
            _currentPage++;
          } else if (result.isFailure) {
            _hasError = true;
            final error = result.error;
            if (error != null) {
              _errorMessage = '${error.message} (Code: ${error.statusCode})';
            } else {
              _errorMessage = 'Failed to load categories - Unknown error';
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _refreshCategories() async {
    await _loadCategories(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError && _categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Failed to load categories',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading &&
            _hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          print('🔄 Triggering load more categories. isLoading: $_isLoading, hasMore: $_hasMore');
          _loadCategories();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _categories.length && _hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (index >= _categories.length) {
            return const SizedBox.shrink();
          }

          final category = _categories[index];
          return CategoryCard(
            category: category,
            onTap: () {
              // Navigate to paginated books screen for this category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaginatedBooksScreen(
                    config: BooksScreenConfig(
                      source: BooksDataSource.category,
                      title: category.name,
                      categoryId: category.id,
                      sortBy: 'random',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}