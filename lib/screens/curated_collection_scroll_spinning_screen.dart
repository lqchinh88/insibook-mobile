import 'package:flutter/material.dart';
import '../widgets/scrolling_book_reveal_widget.dart';
import '../models/curated_collection_models.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../screens/book_details_screen.dart';
import 'package:provider/provider.dart';

class CuratedCollectionScrollSpinningScreen extends StatefulWidget {
  final String collectionId;

  const CuratedCollectionScrollSpinningScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<CuratedCollectionScrollSpinningScreen> createState() => _CuratedCollectionScrollSpinningScreenState();
}

class _CuratedCollectionScrollSpinningScreenState extends State<CuratedCollectionScrollSpinningScreen> {
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;
  bool _contentRevealed = false;

  CuratedCollection? _curatedCollection;
  List<CuratedCollectionItem> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
    _loadCollectionData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCollectionData() async {
    try {
      final bookApiService = BookApiService();
      final currentLanguage = context.read<LanguageProvider>().currentLanguage;
      final result = await bookApiService.getCuratedCollectionDetails(
        collectionId: widget.collectionId,
        language: currentLanguage,
      );

      if (mounted) {
        setState(() {
          if (result.isSuccess && result.value != null) {
            _curatedCollection = result.value!;
            _books = result.value!.items ?? [];
            _isLoading = false;
          } else {
            _errorMessage = result.error?.message ?? context.read<LanguageProvider>().l10n['failed_to_load_collection'];
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${context.read<LanguageProvider>().l10n['failed_to_load_collection']}: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients || _books.isEmpty) return;

    final currentScroll = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;

    // Reduced total height to make animations start earlier
    // Total sections: book covers (screenHeight each) + book details (reduced to 300px each)
    final totalHeight = (screenHeight * _books.length) + (300 * _books.length) + 100; // reduced spacing
    final newProgress = (currentScroll / totalHeight).clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        _scrollProgress = newProgress;
      });
    }
  }

  // Helper methods for individual book section progress calculation
  double _calculateBookSectionProgress(int sectionIndex) {
    if (!_scrollController.hasClients) return 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    final currentScroll = _scrollController.offset;

    // Reduced spacing between sections for earlier animations
    final sectionHeight = screenHeight;
    final sectionStartOffset = sectionIndex ~/ 2 * (screenHeight + 300); // Reduced from 400 to 300
    final sectionEndOffset = sectionStartOffset + sectionHeight;

    // Start animation earlier by extending the trigger range
    final earlyStartOffset = sectionStartOffset - 100; // Start 100px earlier
    final extendedEndOffset = sectionEndOffset + 50; // End 50px later for smoother transition

    if (currentScroll <= earlyStartOffset) return 0.0;
    if (currentScroll >= extendedEndOffset) return 1.0;

    return ((currentScroll - earlyStartOffset) / (extendedEndOffset - earlyStartOffset)).clamp(0.0, 1.0);
  }

  // Widget for individual book details
  Widget _buildBookDetails(CuratedCollectionItem collectionItem, int sectionIndex) {
    final theme = Theme.of(context);
    final book = collectionItem.book;

    // Get localized content with fallbacks (API resolves to direct fields when language param is provided)
    final reasonForInclusion = collectionItem.reasonForInclusion?.isNotEmpty == true
        ? collectionItem.reasonForInclusion!
        : 'No specific reason provided for this book\'s inclusion.';
    final keyTakeaways = collectionItem.keyTakeaways?.isNotEmpty == true
        ? collectionItem.keyTakeaways!
        : 'No key takeaways available for this book.';
    final prerequisites = collectionItem.prerequisites?.isNotEmpty == true
        ? collectionItem.prerequisites!
        : 'No specific prerequisites for reading this book.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title
          Text(
            book.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Author
          Text(
            'by ${book.authors.join(', ')}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // Decorative divider
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Book description
          if (book.description != null) ...[
            Text(
              book.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Curatorial content - Reason for Inclusion
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.read<LanguageProvider>().l10n['why_this_book'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reasonForInclusion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Key Takeaways
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.read<LanguageProvider>().l10n['key_takeaways'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  keyTakeaways,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Prerequisites
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.read<LanguageProvider>().l10n['prerequisites'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  prerequisites,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rating if available
          if (book.goodreadsBook != null) ...[
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${book.goodreadsBook!.starRating.toStringAsFixed(1)} / 5.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${book.goodreadsBook!.numRatings} ratings)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Read Summary Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to book details screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(
                      book: book,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: Text(context.read<LanguageProvider>().l10n['read_summary']),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 6,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Loading state
          if (_isLoading)
            _buildLoadingState()

          // Error state
          else if (_errorMessage != null)
            _buildErrorState()

          // Content state
          else if (_books.isNotEmpty)
            _buildContentState(screenHeight, theme),

          // Back button (highest z-index)
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            context.read<LanguageProvider>().l10n['loading_collection'],
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.read<LanguageProvider>().l10n['failed_to_load_collection'],
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? context.read<LanguageProvider>().l10n['unknown_error_occurred'],
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCollectionData,
              child: Text(context.read<LanguageProvider>().l10n['retry_collection']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentState(double screenHeight, ThemeData theme) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Linear book flow: cover animation → details → next book
        ...List.generate(_books.length * 2, (index) {
          final bookIndex = index ~/ 2; // Each book gets 2 sections: cover + details
          final isCoverSection = index % 2 == 0;

          if (isCoverSection) {
            // Book cover animation section
            return SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight, // Full screen height for book animation
                child: Center(
                  child: ScrollingBookRevealWidget(
                    bookCoverUrl: _books[bookIndex].book.displayImageUrl ?? '',
                    bookTitle: _books[bookIndex].book.title,
                    bookAuthor: _books[bookIndex].book.authors.join(', '),
                    scrollProgress: _calculateBookSectionProgress(index),
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            );
          } else {
            // Book details section
            return SliverToBoxAdapter(
              child: _buildBookDetails(_books[bookIndex], index),
            );
          }
        }),

  
        // Footer
        SliverToBoxAdapter(
          child: SizedBox(height: 100), // Extra padding at bottom
        ),
      ],
    );
  }

  }