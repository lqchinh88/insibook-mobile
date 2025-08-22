import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_service.dart';
import '../widgets/horizontal_book_card.dart';
import '../widgets/category_card.dart';
import 'grid_layout_book_screen.dart';
import 'book_search_screen.dart';

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
  bool _isSearchExpanded = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  
  static const int _horizontalLimit = 20;

  @override
  void initState() {
    super.initState();
    _loadLatestBooks();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestBooks() async {
    if (_isLoadingLatest) return;

    setState(() {
      _isLoadingLatest = true;
    });

    try {
      final response = await BookApiService.getLatestBooks(
        limit: _horizontalLimit,
        offset: 0,
      );

      if (response != null) {
        setState(() {
          _latestBooks = response.books;
        });
      }
    } catch (e) {
      // Handle error silently for horizontal sections
    } finally {
      setState(() {
        _isLoadingLatest = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    if (_isLoadingCategories) return;

    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await BookApiService.getAllCategories();
      if (categories != null && mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Handle error silently for categories
      if (mounted) {
        setState(() {
          _categories = <BookCategory>[];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular((_isSearchExpanded) ? 16 : 25),
            ),
            child: TextField(
              controller: _titleController,
              onTap: () {
                if (!(_isSearchExpanded)) {
                  setState(() {
                    _isSearchExpanded = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sách bạn cần',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _isSearchExpanded
                    ? IconButton(
                        icon: Icon(Icons.keyboard_arrow_up, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = false;
                            _titleController.clear();
                            _authorController.clear();
                          });
                        },
                      )
                    : Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Expanded search form
          if (_isSearchExpanded) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Author field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        hintText: 'Tác giả (tùy chọn)',
                        prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Find button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _performSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tìm kiếm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  void _performSearch() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    
    if (title.isEmpty && author.isEmpty) {
      // Show error message if both fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất tên sách hoặc tác giả'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Navigate to search screen with pre-filled data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookSearchScreen(
          initialTitle: title.isNotEmpty ? title : null,
          initialAuthor: author.isNotEmpty ? author : null,
        ),
      ),
    );
    
    // Collapse the search bar and clear fields
    setState(() {
      _isSearchExpanded = false;
      _titleController.clear();
      _authorController.clear();
    });
  }

  Widget _buildFeaturedBook() {
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
                  const Text(
                    'Sách mới tuần này',
                    style: TextStyle(
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
                      'Từ tác giả ${book.authors.first}',
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
                    child: const Text(
                      'Xem Ngay',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildReadingProgress() {
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
                const Text(
                  'Bạn đã đạt 68% mục tiêu đọc của tháng',
                  style: TextStyle(
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
                const Text(
                  'Hoàn thành để nhận 1 tháng tài khoản VIP',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
            child: const Text(
              'VIP',
              style: TextStyle(
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

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
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
              child: const Text('View All'),
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

  Widget _buildCategoryGrid() {
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
            'Không có danh mục nào',
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
                _buildSearchBar(),
                
                _buildFeaturedBook(),
                
                _buildReadingProgress(),
                
                const SizedBox(height: 16),
                
                _buildSectionHeader('Sách nói gợi ý cho bạn', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GridLayoutBookScreen(
                        title: 'Sách nói gợi ý',
                        category: 'latest',
                      ),
                    ),
                  );
                }),
                
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
                
                _buildSectionHeader('Khám phá theo danh mục', () {}),
                
                _buildCategoryGrid(),
                
                const SizedBox(height: 24),
                
                _buildSectionHeader('Sách mới', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GridLayoutBookScreen(
                        title: 'Sách mới',
                        category: 'latest',
                      ),
                    ),
                  );
                }),
                
                if (!_isLoadingLatest)
                  _buildHorizontalBookList(_latestBooks.take(10).toList()),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}