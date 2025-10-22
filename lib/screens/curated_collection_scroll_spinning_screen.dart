import 'package:flutter/material.dart';
import '../widgets/scrolling_book_reveal_widget.dart';
import '../widgets/book_details/book_info_section.dart';
import '../widgets/book_details/book_description_section.dart';
import '../widgets/book_details/curated_content_section.dart';
import '../widgets/book_details/book_action_button.dart';
import '../models/curated_collection_models.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../constants/scroll_animation_constants.dart';
import '../utils/performance_monitor.dart';
import 'package:provider/provider.dart';

/// Widget that measures its own size and reports back via callback
class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;

  const MeasureSize({super.key, required this.onChange, required this.child});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  void didUpdateWidget(MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      WidgetsBinding.instance.addPostFrameCallback(_notifySize);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_notifySize);
  }

  void _notifySize(_) {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    widget.onChange(size);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class CuratedCollectionScrollSpinningScreen extends StatefulWidget {
  final String collectionId;

  const CuratedCollectionScrollSpinningScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<CuratedCollectionScrollSpinningScreen> createState() =>
      _CuratedCollectionScrollSpinningScreenState();
}

class _CuratedCollectionScrollSpinningScreenState
    extends State<CuratedCollectionScrollSpinningScreen> {
  late ScrollController _scrollController;

  List<CuratedCollectionItem> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Track actual measured heights for each book's details section
  final Map<int, double> _bookDetailsHeights = <int, double>{};

  // Performance monitoring (disabled in production)
  late PerformanceMonitor _performanceMonitor;
  static const bool _enablePerformanceMonitoring =
      false; // Set to true for debugging

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);

    // Only enable performance monitoring in debug mode
    if (_enablePerformanceMonitoring) {
      _performanceMonitor = PerformanceMonitor();
      _performanceMonitor.startMonitoring();
    }

    _loadCollectionData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();

    if (_enablePerformanceMonitoring) {
      _performanceMonitor.stopMonitoring();
    }

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
            _books = result.value!.items ?? [];
            _isLoading = false;
          } else {
            _errorMessage =
                result.error?.message ??
                context
                    .read<LanguageProvider>()
                    .l10n['failed_to_load_collection'];
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              '${context.read<LanguageProvider>().l10n['failed_to_load_collection']}: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _updateScrollProgress() {
    // Trigger rebuild only when needed for scroll position updates
    if (mounted && _books.isNotEmpty) {
      setState(() {});
    }
  }

  // Calculate cumulative height up to a specific book's cover section
  // This determines where each book's animation should start based on the total height of all previous sections
  double _getCumulativeHeightUpToBook(int bookIndex) {
    if (bookIndex == 0) return 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    double totalHeight = 0.0;

    for (int i = 0; i < bookIndex; i++) {
      // Add full screen height for each previous book's cover animation section
      totalHeight += screenHeight;

      // Add the actual measured height of each book's details section
      // Falls back to constant estimate if measurement not yet available
      final detailsHeight =
          _bookDetailsHeights[i] ?? ScrollAnimationConstants.bookDetailsHeight;
      totalHeight += detailsHeight;
    }

    return totalHeight;
  }

  // Helper methods for individual book section progress calculation
  double _calculateBookSectionProgress(int sectionIndex) {
    if (!_scrollController.hasClients) return 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    final currentScroll = _scrollController.offset;
    final bookIndex = sectionIndex ~/ 2; // Convert section to book index

    // Calculate actual start position based on cumulative heights of previous books
    final sectionStartOffset = _getCumulativeHeightUpToBook(bookIndex);
    final sectionEndOffset =
        sectionStartOffset +
        screenHeight; // Cover sections span one screen height

    // Use constants for animation trigger range
    final earlyStartOffset =
        sectionStartOffset + ScrollAnimationConstants.earlyAnimationStart;
    final extendedEndOffset =
        sectionEndOffset + ScrollAnimationConstants.extendedAnimationEnd;

    if (currentScroll <= earlyStartOffset) return 0.0;
    if (currentScroll >= extendedEndOffset) return 1.0;

    final progress =
        ((currentScroll - earlyStartOffset) /
                (extendedEndOffset - earlyStartOffset))
            .clamp(0.0, 1.0);
    return progress;
  }

  // Widget that measures its own height and reports it back
  Widget _buildMeasuredBookDetails(
    CuratedCollectionItem collectionItem,
    int sectionIndex,
  ) {
    final bookIndex = sectionIndex ~/ 2;

    return MeasureSize(
      onChange: (Size size) {
        // Update the measured height for this book
        setState(() {
          _bookDetailsHeights[bookIndex] = size.height;
        });
      },
      child: _buildBookDetails(collectionItem, sectionIndex),
    );
  }

  // Widget for individual book details - now using modular components
  Widget _buildBookDetails(
    CuratedCollectionItem collectionItem,
    int sectionIndex,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          // Book info (title, author, rating)
          BookInfoSection(collectionItem: collectionItem),

          // Book description
          BookDescriptionSection(collectionItem: collectionItem),

          // Curated content sections (reason, takeaways, prerequisites)
          CuratedContentSection(collectionItem: collectionItem),

          const SizedBox(height: 16),

          // Action button
          BookActionButton(collectionItem: collectionItem),
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
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
          CircularProgressIndicator(color: theme.colorScheme.primary),
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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              context
                  .read<LanguageProvider>()
                  .l10n['failed_to_load_collection'],
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ??
                  context
                      .read<LanguageProvider>()
                      .l10n['unknown_error_occurred'],
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCollectionData,
              child: Text(
                context.read<LanguageProvider>().l10n['retry_collection'],
              ),
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
          final bookIndex =
              index ~/ 2; // Each book gets 2 sections: cover + details
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
              child: _buildMeasuredBookDetails(_books[bookIndex], index),
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
