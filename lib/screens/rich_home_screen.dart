import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../utils/result.dart';
import '../providers/book_api_provider.dart';
import '../providers/language_provider.dart';
import '../lang/app_localizations.dart';
import '../services/book_api_service.dart';
import '../widgets/horizontal_book_card.dart';
import '../widgets/category_card.dart';
import 'grid_layout_book_screen.dart';

class RichHomeScreen extends StatefulWidget {
  const RichHomeScreen({super.key});

  @override
  State<RichHomeScreen> createState() => _RichHomeScreenState();
}

class _RichHomeScreenState extends State<RichHomeScreen> {
  List<InternalBookItem> _latestBooks = [];
  bool _isLoadingLatest = false;
  List<BookCategory> _categories = <BookCategory>[];
  bool _isLoadingCategories = false;
  late final BookApiService _bookApiService;
  
  static const int _horizontalLimit = 20;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _loadLatestBooks();
    _loadCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLatestBooks() async {
    if (_isLoadingLatest) return;

    if (mounted) {
      setState(() {
        _isLoadingLatest = true;
      });
    }

    final result = await _bookApiService.getLatestBooks(
      limit: _horizontalLimit,
      offset: 0,
    );

    result.fold(
      (response) {
        if (mounted) {
          setState(() {
            _latestBooks = response.books;
            _isLoadingLatest = false;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _isLoadingLatest = false;
          });
        }
      },
    );
  }

  Future<void> _loadCategories() async {
    if (_isLoadingCategories) return;

    if (mounted) {
      setState(() {
        _isLoadingCategories = true;
      });
    }

    final result = await _bookApiService.getAllCategories();

    result.fold(
      (categories) {
        if (mounted) {
          setState(() {
            _categories = categories;
            _isLoadingCategories = false;
          });
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _categories = <BookCategory>[];
            _isLoadingCategories = false;
          });
        }
      },
    );
  }


  Widget _buildFeaturedBook(AppLocalizations l10n) {
    if (_latestBooks.isEmpty) return const SizedBox.shrink();
    
    final book = _latestBooks.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[400]!,
            Colors.blue[600]!,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n['latest_books_this_week'] ?? 'New books this week',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (book.authors.isNotEmpty)
                    Text(
                      '${l10n['by_author'] ?? 'By '}${book.authors.first}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: Text(
                      l10n['view_now'] ?? 'View Now',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.displayImageUrl != null
                      ? Image.network(
                          book.displayImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 40),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgress(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n['monthly_goal_progress'] ?? 'You have achieved 68% of this month\'s reading goal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.68,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n['vip_reward_message'] ?? 'Complete to get 1 month VIP account',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n['vip'] ?? 'VIP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(l10n['view_all'] ?? 'View All'),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBookList(List<InternalBookItem> books) {
    return SizedBox(
      height: 280,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
          scrollbars: false,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return HorizontalBookCard(book: books[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(AppLocalizations l10n) {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            l10n['no_categories'] ?? 'No categories available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryCard(
            category: category,
            onTap: () {
              // TODO: Navigate to category books screen
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  _loadLatestBooks(),
                  _loadCategories(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedBook(l10n),
                    
                    _buildReadingProgress(l10n),
                    
                    const SizedBox(height: 16),
                    
                    _buildSectionHeader(l10n['suggested_audiobooks'] ?? 'Suggested audiobooks for you', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GridLayoutBookScreen(
                            title: l10n['suggested_audiobooks_short'] ?? 'Suggested audiobooks',
                            category: 'latest',
                          ),
                        ),
                      );
                    }, l10n),
                    
                    if (_isLoadingLatest)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildHorizontalBookList(_latestBooks),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader(l10n['explore_by_category'] ?? 'Explore by category', () {}, l10n),
                    
                    _buildCategoryGrid(l10n),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader(l10n['new_books'] ?? 'New books', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GridLayoutBookScreen(
                            title: l10n['new_books'] ?? 'New books',
                            category: 'latest',
                          ),
                        ),
                      );
                    }, l10n),
                    
                    if (!_isLoadingLatest)
                      _buildHorizontalBookList(_latestBooks.take(10).toList()),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}