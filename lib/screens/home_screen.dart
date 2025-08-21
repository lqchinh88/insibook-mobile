import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_service.dart';
import '../widgets/horizontal_book_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InternalBookItem> _latestBooks = [];
  bool _isLoadingLatest = false;
  
  static const int _horizontalLimit = 20;

  @override
  void initState() {
    super.initState();
    _loadLatestBooks();
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

  Widget _buildAppBar() {
    return AppBar(
      title: const Text('InsiBook'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<InternalBookItem> books,
    required bool isLoading,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
                  ? const Center(
                      child: Text(
                        'No books available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return HorizontalBookCard(book: books[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to InsiBook',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Discover amazing book summaries and expand your knowledge',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
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
      body: RefreshIndicator(
        onRefresh: () => _loadLatestBooks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 16),
              _buildHorizontalSection(
                title: 'Latest Books',
                books: _latestBooks,
                isLoading: _isLoadingLatest,
                onSeeAll: () {
                  // Navigate to see all latest books
                },
              ),
              const SizedBox(height: 24),
              // Add more sections here in the future
              // Example:
              // _buildHorizontalSection(
              //   title: 'Popular This Week',
              //   books: _popularBooks,
              //   isLoading: _isLoadingPopular,
              // ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}