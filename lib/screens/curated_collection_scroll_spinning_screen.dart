import 'package:flutter/material.dart';
import '../widgets/scrolling_book_reveal_widget.dart';
import '../models/curated_collection_models.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
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
      final result = await bookApiService.getCuratedCollectionDetails(
        collectionId: widget.collectionId,
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

    // Total sections: book covers (screenHeight each) + book details (estimated 400px each) + collection summary
    final totalSections = _books.length * 2; // cover + details for each book
    final totalHeight = (screenHeight * _books.length) + (400 * _books.length) + 600; // summary section
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

    // Each book cover gets full screen height
    final sectionHeight = screenHeight;
    final sectionStartOffset = sectionIndex ~/ 2 * (screenHeight + 400); // Every other section is a cover
    final sectionEndOffset = sectionStartOffset + sectionHeight;

    if (currentScroll <= sectionStartOffset) return 0.0;
    if (currentScroll >= sectionEndOffset) return 1.0;

    return ((currentScroll - sectionStartOffset) / sectionHeight).clamp(0.0, 1.0);
  }

  // Widget for individual book details
  Widget _buildBookDetails(CuratedCollectionItem collectionItem, int sectionIndex) {
    final theme = Theme.of(context);
    final book = collectionItem.book;

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

          // Curatorial content
          if (collectionItem.reasonForInclusion != null) ...[
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
                    collectionItem.reasonForInclusion!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (collectionItem.keyTakeaways != null) ...[
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
                    collectionItem.keyTakeaways!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (collectionItem.prerequisites != null) ...[
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
                    collectionItem.prerequisites!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
          ],
        ],
      ),
    );
  }

  // Helper methods for scroll-based content reveal
  Widget _buildScrollRevealedContent({
    required Widget child,
    required double opacity,
    required double yOffset,
    required double delay,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: (200 + delay).round()),
      transform: Matrix4.translationValues(0, yOffset, 0),
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }

  double _calculateContentOpacity(double startThreshold) {
    if (_scrollProgress <= startThreshold) return 0.0;

    final fadeDuration = 0.2; // 20% of scroll for fade in
    final endThreshold = (startThreshold + fadeDuration).clamp(0.0, 1.0);

    if (_scrollProgress >= endThreshold) return 1.0;

    // Linear interpolation from startThreshold to endThreshold
    return (_scrollProgress - startThreshold) / fadeDuration;
  }

  double _calculateContentYOffset(double startThreshold) {
    if (_scrollProgress <= startThreshold) return 50.0; // Start position

    final moveDuration = 0.15; // 15% of scroll for movement
    final endThreshold = (startThreshold + moveDuration).clamp(0.0, 1.0);

    if (_scrollProgress >= endThreshold) return 0.0; // Final position

    // Linear interpolation from 50px to 0px
    final progress = (_scrollProgress - startThreshold) / moveDuration;
    return 50.0 * (1.0 - progress);
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

        // Final collection summary section
        SliverToBoxAdapter(
          child: _buildCollectionSummary(),
        ),

        // Footer
        SliverToBoxAdapter(
          child: SizedBox(height: 100), // Extra padding at bottom
        ),
      ],
    );
  }

  Widget _buildBookHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Header title
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Text(
                    context.read<LanguageProvider>().l10n['featured_collection'],
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // List of book titles
          ..._books.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1000 + (index * 200)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${index + 1}. ${book.book.title} — ${book.book.authors.join(', ')}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          const SizedBox(height: 32),

          // Decorative divider
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  width: 100,
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
              );
            },
          ),
        ],
      ),
    );
  }

  
  Widget _buildCollectionSummary() {
    final theme = Theme.of(context);
    final collection = _curatedCollection;

    if (collection == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  collection.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Curator info
          if (collection.curatorName != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${context.read<LanguageProvider>().l10n['curated_by']} ${collection.curatorName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Collection description
          if (collection.description != null) ...[
            Text(
              collection.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Collection stats
          Row(
            children: [
              Icon(
                Icons.menu_book,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${collection.bookCount} ${context.read<LanguageProvider>().l10n['books_in_collection']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<LanguageProvider>().l10n['starting_to_read_collection'].replaceAll('{collection}', collection.title)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.read<LanguageProvider>().l10n['start_reading_collection'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesSection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: 16),
          ..._books.asMap().entries.map((entry) {
            final index = entry.key;
            final quotes = [
              '"So we beat on, boats against the current, borne back ceaselessly into the past."',
              '"You never really understand a person until you consider things from his point of view... until you climb into his skin and walk around in it."',
              '"War is peace. Freedom is slavery. Ignorance is strength."',
            ];
            final authors = [
              '— F. Scott Fitzgerald',
              '— Harper Lee',
              '— George Orwell',
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quotes[index],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authors[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (index < _books.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildDetailCard(
            icon: Icons.star_rounded,
            title: context.read<LanguageProvider>().l10n['rating'],
            content: '4.7 / 5.0',
            subtitle: '2.3M reviews',
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.schedule_rounded,
            title: context.read<LanguageProvider>().l10n['reading_time'],
            content: '3-4 hours',
            subtitle: '180 pages',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.category_rounded,
            title: context.read<LanguageProvider>().l10n['genre'],
            content: context.read<LanguageProvider>().l10n['classic_fiction'],
            subtitle: context.read<LanguageProvider>().l10n['literary_novel'],
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<LanguageProvider>().l10n['starting_to_read_collection_generic']),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.read<LanguageProvider>().l10n['start_reading'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.read<LanguageProvider>().l10n['back_to_library'],
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}