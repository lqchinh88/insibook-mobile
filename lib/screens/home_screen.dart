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
import 'grid_layout_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InternalBookItem> _latestBooks = [];
  bool _isLoadingLatest = false;
  late final BookApiService _bookApiService;
  
  static const int _horizontalLimit = 20;

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _loadLatestBooks();
  }

  Future<void> _loadLatestBooks() async {
    if (_isLoadingLatest) return;

    setState(() {
      _isLoadingLatest = true;
    });

    final response = await _bookApiService.getLatestBooks(
      limit: _horizontalLimit,
      offset: 0,
    );

    response.fold(
      (bookResponse) {
        setState(() {
          _latestBooks = bookResponse.books;
        });
      },
      (error) {
        // Handle error silently for horizontal sections
      },
    );
    
    setState(() {
      _isLoadingLatest = false;
    });
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n['app_title'] ?? 'InsiBook'),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<InternalBookItem> books,
    required bool isLoading,
    required AppLocalizations l10n,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(l10n['see_all'] ?? 'See All'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
                  ? Center(
                      child: Text(
                        l10n['no_books_available'] ?? 'No books available',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ScrollConfiguration(
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
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(AppLocalizations l10n) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n['welcome_to_insibook'] ?? 'Welcome to InsiBook',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n['discover_message'] ?? 'Discover amazing book summaries and expand your knowledge',
            style: const TextStyle(
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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: _buildAppBar(l10n),
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadLatestBooks(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildWelcomeSection(l10n),
                  const SizedBox(height: 16),
                  _buildHorizontalSection(
                    title: l10n['latest_books'] ?? 'Latest Books',
                    books: _latestBooks,
                    isLoading: _isLoadingLatest,
                    l10n: l10n,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GridLayoutBookScreen(
                            title: l10n['latest_books'] ?? 'Latest Books',
                            category: 'latest',
                          ),
                        ),
                      );
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
      },
    );
  }
}