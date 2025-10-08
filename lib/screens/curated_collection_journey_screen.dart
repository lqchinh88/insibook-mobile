import 'package:flutter/material.dart';
import '../models/journey_book_data.dart';
import '../widgets/curated_collection_journey_widgets.dart';

class CuratedCollectionJourneyScreen extends StatefulWidget {
  const CuratedCollectionJourneyScreen({super.key});

  @override
  State<CuratedCollectionJourneyScreen> createState() => _CuratedCollectionJourneyScreenState();
}

class _CuratedCollectionJourneyScreenState extends State<CuratedCollectionJourneyScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<JourneyBookData> _curatorialBooks;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _curatorialBooks = JourneyBookData.getJourneyBooks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main horizontal PageView for book switching
          _buildPageView(),

          // Overlay UI elements
          _buildOverlayElements(),
        ],
      ),
    );
  }

  Widget _buildPageView() {
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

        // Page indicator
        _buildPageIndicator(),

        // Navigation dots
        _buildNavigationDots(),
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