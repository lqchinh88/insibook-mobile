import 'package:flutter/material.dart';
import '../models/journey_book_data.dart';
import '../models/curated_collection_models.dart';
import '../widgets/curated_collection_journey_widgets.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';

class CuratedCollectionJourneyScreen extends StatefulWidget {
  final String collectionId;

  const CuratedCollectionJourneyScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<CuratedCollectionJourneyScreen> createState() => _CuratedCollectionJourneyScreenState();
}

class _CuratedCollectionJourneyScreenState extends State<CuratedCollectionJourneyScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<JourneyBookData> _curatorialBooks;

  CuratedCollection? _curatedCollection;
  List<CuratedCollectionItem> _collectionItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCollectionData();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            _collectionItems = result.value!.items ?? [];
            _curatorialBooks = _convertCollectionItemsToJourneyBooks(_collectionItems);
            _isLoading = false;
          } else {
            _errorMessage = result.error?.message ?? 'Failed to load collection';
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load collection: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<JourneyBookData> _convertCollectionItemsToJourneyBooks(List<CuratedCollectionItem> items) {
    return items.map((item) {
      final book = item.book;
      return JourneyBookData(
        title: book.title,
        author: book.authors.join(', '),
        coverUrl: book.displayImageUrl ?? '',
        whyThisBook: item.reasonForInclusion ?? 'This book has been carefully selected for this collection due to its unique contribution to the overall theme and narrative journey.',
        thematicConnections: item.keyTakeaways ?? 'This work connects deeply with other pieces in the collection, creating meaningful dialogues and reinforcing our central themes.',
        keyInsights: book.description ?? 'This book offers profound insights that will enrich your understanding and perspective on the collection\'s core themes.',
        collectionContext: _curatedCollection?.description ?? 'This book finds its perfect place within our curated journey, contributing to a comprehensive exploration of our chosen subject.',
        curatorQuote: 'Each book in this collection has been chosen with intention and care to create a meaningful literary experience.',
      );
    }).toList();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Loading state
          if (_isLoading)
            _buildLoadingState()

          // Error state
          else if (_errorMessage != null)
            _buildErrorState()

          // Content state
          else
            Stack(
              children: [
                // Main horizontal PageView for book switching
                _buildPageView(),

                // Overlay UI elements
                _buildOverlayElements(),
              ],
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
            'Loading collection...',
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
              'Failed to load collection',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCollectionData,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No books in this collection',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This curated collection doesn\'t contain any books yet.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    if (_curatorialBooks.isEmpty) {
      return _buildEmptyState();
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      scrollDirection: Axis.horizontal,
      itemCount: _curatorialBooks.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, bookIndex) {
        return _buildBookPage(_curatorialBooks[bookIndex], bookIndex);
      },
    );
  }

  Widget _buildOverlayElements() {
    return Stack(
      children: [
        // Back button
        _buildBackButton(),

        // Only show page indicator and navigation dots if there are books
        if (_curatorialBooks.isNotEmpty) ...[
          // Page indicator
          _buildPageIndicator(),

          // Navigation dots
          _buildNavigationDots(),
        ],
      ],
    );
  }

  Widget _buildBookPage(JourneyBookData book, int bookIndex) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Book cover section - full screen
          _buildBookCoverSection(book, bookIndex),

          // Curatorial content section
          _buildContentSection(book, bookIndex),
        ],
      ),
    );
  }

  Widget _buildBookCoverSection(JourneyBookData book, int bookIndex) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: JourneyBookCoverWidget(book: book),
    );
  }

  Widget _buildContentSection(JourneyBookData book, int bookIndex) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book header
            JourneyContentHeaderWidget(
              title: book.title,
              author: book.author,
            ),
            const SizedBox(height: 40),

            // Content sections
            ..._buildContentSections(book),

            const SizedBox(height: 60),

            // Navigation hint
            const JourneyNavigationHintWidget(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentSections(JourneyBookData book) {
    return [
      JourneyContentSectionWidget(
        title: 'Why This Book',
        content: book.whyThisBook,
        icon: Icons.star_rounded,
      ),
      const SizedBox(height: 32),

      JourneyContentSectionWidget(
        title: 'Thematic Connections',
        content: book.thematicConnections,
        icon: Icons.link_rounded,
      ),
      const SizedBox(height: 32),

      JourneyContentSectionWidget(
        title: 'Key Insights',
        content: book.keyInsights,
        icon: Icons.lightbulb_rounded,
      ),
      const SizedBox(height: 32),

      JourneyContentSectionWidget(
        title: 'Collection Context',
        content: book.collectionContext,
        icon: Icons.public_rounded,
      ),
      const SizedBox(height: 40),

      JourneyCuratorQuoteWidget(quote: book.curatorQuote),
    ];
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 50,
      right: 16,
      child: JourneyPageIndicatorWidget(
        currentPage: _currentPage + 1,
        totalPages: _curatorialBooks.length,
      ),
    );
  }

  Widget _buildNavigationDots() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: JourneyNavigationDotsWidget(
        currentIndex: _currentPage,
        totalItems: _curatorialBooks.length,
      ),
    );
  }
}