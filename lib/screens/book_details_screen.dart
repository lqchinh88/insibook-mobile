import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:forui/forui.dart';
import '../models/book_models.dart';
import '../services/book_api_service.dart';
import '../providers/language_provider.dart';
import '../providers/book_api_provider.dart';
import '../utils/result.dart';
import 'book_content_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final InternalBookItem book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

enum NavigationState {
  expanded, // Buttons follow separator line
  collapsed, // Navigation bar visible with buttons
  floating, // Buttons float with separator again
}

class _CustomNavigationBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onReadPressed;
  final String? selectedLanguage;
  final Function(String?) onLanguageChanged;
  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;

  const _CustomNavigationBar({
    required this.onBackPressed,
    required this.onReadPressed,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.isBookmarked,
    required this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).padding.top + 75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                ),
              ),

              const SizedBox(width: 12),

              // Bookmark button
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isBookmarked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isBookmarked ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onBookmarkPressed,
                    child: Center(
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isBookmarked ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action buttons on the right
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Read Summary button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FButton(
                      onPress: onReadPressed,
                      prefix: const Icon(
                        Icons.book_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      child: Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) => Text(
                          langProvider.l10n['read_summary'] ?? 'Read',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Language selector button
                  Consumer<LanguageProvider>(
                    builder: (context, langProvider, child) => SizedBox(
                      width: 95,
                      child: FSelect<String>.rich(
                        hint: selectedLanguage == 'en' ? 'EN' : 'VN',
                        format: (value) => value == 'en' ? 'EN' : 'VN',
                        children: [
                          FSelectItem(value: 'en', title: Text('EN')),
                          FSelectItem(value: 'vi', title: Text('VN')),
                        ],
                        onChange: onLanguageChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late final BookApiService _bookApiService;
  BookWithContent? _bookDetails;
  bool _isLoading = false;
  bool _hasError = false;
  String? _selectedSummaryLanguage;
  final ScrollController _scrollController = ScrollController();
  NavigationState _navigationState = NavigationState.expanded;
  bool _isBookmarked = false;

  final List<Map<String, String>> _availableLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'vi', 'name': 'Tiếng Việt'},
  ];

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    _isBookmarked = widget.book.isBookmarked ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial summary language to app language
      final langProvider = context.read<LanguageProvider>();
      _selectedSummaryLanguage = langProvider.currentLanguage;
      _loadBookDetails();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookDetails() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _bookApiService.getBookWithContent(
        bookId: widget.book.id,
        summaryLanguage: _selectedSummaryLanguage ?? 'en',
      );
      result.fold(
        (bookDetails) {
          setState(() {
            _bookDetails = bookDetails;
            _isBookmarked = bookDetails.isBookmarked ?? false;
            _isLoading = false;
          });
        },
        (error) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => Text(
              langProvider.l10n['book_details'] ?? 'Book Details',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _bookDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => Text(
              langProvider.l10n['book_details'] ?? 'Book Details',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: Center(
          child: Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  langProvider.l10n['error_loading_book'] ??
                      'Error loading book details',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                FButton(
                  onPress: _loadBookDetails,
                  child: Text(langProvider.l10n['retry'] ?? 'Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(body: _buildStickyHeaderLayout());
  }

  Widget _buildStickyHeaderLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxCoverHeight = screenHeight * 0.4;
    final minCoverHeight =
        MediaQuery.of(context).padding.top +
        80; // Status bar + minimal header height

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sticky cover header with shrinking behavior
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                minHeight: minCoverHeight,
                maxHeight: maxCoverHeight,
                child: _buildCoverContent(),
              ),
            ),

            // Main content area
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and author
                    Text(
                      _bookDetails!.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                    if (_bookDetails!.authors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'by ${_bookDetails!.authors.join(', ')}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],

                    // Goodreads ratings and information
                    if (_bookDetails!.hasGoodreadsData) ...[
                      const SizedBox(height: 16),
                      _buildGoodreadsInfo(context),
                    ],

                    // Categories section
                    if (_bookDetails!.categories.isNotEmpty) ...[
                      Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) => Text(
                          langProvider.l10n['categories'] ?? 'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _bookDetails!.categories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Description section
                    if (_bookDetails!.description != null &&
                        _bookDetails!.description!.isNotEmpty) ...[
                      Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) => Text(
                          langProvider.l10n['about_this_book'] ??
                              'About this book',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _bookDetails!.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                      ),
                    ],

                    // Introduction section
                    if (_bookDetails!.summary.introduction != null &&
                        _bookDetails!.summary.introduction!.isNotEmpty) ...[
                      Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) => Text(
                          langProvider.l10n['introduction'] ?? 'Introduction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _bookDetails!.summary.introduction!,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating action buttons overlay - positioned in main stack for proper z-index
        if (_bookDetails!.summary.content != null ||
            _bookDetails!.summary.chapters.isNotEmpty)
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              // Calculate current header height based on scroll offset
              final scrollOffset = _scrollController.hasClients
                  ? _scrollController.offset
                  : 0.0;
              final currentHeaderHeight = (maxCoverHeight - scrollOffset).clamp(
                minCoverHeight,
                maxCoverHeight,
              );

              // Calculate scroll thresholds for navigation states
              final collapseThreshold =
                  maxCoverHeight -
                  minCoverHeight; // When header fully collapses

              // Determine current navigation state
              NavigationState currentState;
              if (scrollOffset < collapseThreshold) {
                currentState = NavigationState.expanded;
              } else {
                // Once collapsed, stay collapsed (navigation bar visible)
                // The floating state is not used in this implementation
                currentState = NavigationState.collapsed;
              }

              // Update state if changed
              if (currentState != _navigationState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _navigationState = currentState;
                  });
                });
              }

              // Return appropriate widget based on navigation state
              switch (_navigationState) {
                case NavigationState.expanded:
                  // Show floating buttons that follow separator line
                  final buttonTop = currentHeaderHeight - 30;

                  return Positioned(
                    top: buttonTop,
                    right: 24,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Read Summary button
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: FButton(
                                onPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookContentScreen(
                                        bookContent: _bookDetails!,
                                      ),
                                    ),
                                  );
                                },
                                prefix: const Icon(
                                  Icons.book_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                child: Consumer<LanguageProvider>(
                                  builder: (context, langProvider, child) =>
                                      Text(
                                        langProvider.l10n['read_summary'] ??
                                            'Read',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Language selector button
                            Consumer<LanguageProvider>(
                              builder: (context, langProvider, child) =>
                                  SizedBox(
                                    width: 95,
                                    child: FSelect<String>.rich(
                                      hint: _selectedSummaryLanguage == 'en'
                                          ? 'EN'
                                          : 'VN',
                                      format: (value) =>
                                          value == 'en' ? 'EN' : 'VN',
                                      children: [
                                        FSelectItem(
                                          value: 'en',
                                          title: Text('EN'),
                                        ),
                                        FSelectItem(
                                          value: 'vi',
                                          title: Text('VN'),
                                        ),
                                      ],
                                      onChange: (String? newValue) {
                                        if (newValue != null &&
                                            newValue !=
                                                _selectedSummaryLanguage) {
                                          setState(() {
                                            _selectedSummaryLanguage = newValue;
                                          });
                                          _loadBookDetails();
                                        }
                                      },
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                case NavigationState.collapsed:
                  // Return empty positioned widget as navigation bar will be shown separately
                  return const SizedBox.shrink();

                case NavigationState.floating:
                  // Floating state not used in current implementation, but included for completeness
                  return const SizedBox.shrink();
              }
            },
          ),

        // Floating bookmark button - positioned on the left side
        if (_navigationState == NavigationState.expanded)
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
              final currentHeaderHeight = (maxCoverHeight - scrollOffset).clamp(minCoverHeight, maxCoverHeight);
              final buttonTop = currentHeaderHeight - 26;

              return Positioned(
                top: buttonTop,
                left: 24,
                child: Material(
                  color: Colors.transparent,
                  elevation: 10,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: _isBookmarked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                        },
                        child: Center(
                          child: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: _isBookmarked ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Navigation bar overlay - shown only in collapsed state
        if (_navigationState == NavigationState.collapsed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _navigationState == NavigationState.collapsed
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _CustomNavigationBar(
                onBackPressed: () => Navigator.pop(context),
                onReadPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookContentScreen(bookContent: _bookDetails!),
                    ),
                  );
                },
                selectedLanguage: _selectedSummaryLanguage,
                onLanguageChanged: (String? newValue) {
                  if (newValue != null &&
                      newValue != _selectedSummaryLanguage) {
                    setState(() {
                      _selectedSummaryLanguage = newValue;
                    });
                    _loadBookDetails();
                  }
                },
                isBookmarked: _isBookmarked,
                onBookmarkPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoodreadsInfo(BuildContext context) {
    final goodreadsBook = _bookDetails!.goodreadsBook!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Goodreads branding
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Goodreads',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 12),

          // Rating information
          Row(
            children: [
              // Star rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    goodreadsBook.formattedStarRating,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.amber[600], size: 20),
                ],
              ),

              const SizedBox(width: 16),

              // Rating counts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goodreadsBook.formattedRatingCount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (goodreadsBook.numReviews > 0)
                      Text(
                        goodreadsBook.formattedReviewCount,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // About author section
          if (goodreadsBook.aboutAuthor != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'About the author',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${goodreadsBook.aboutAuthor!.name} • ${goodreadsBook.aboutAuthor!.numBooks} books • ${goodreadsBook.aboutAuthor!.numFollowers} followers',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverContent() {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),

        // Centered book cover image
        Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: double.infinity),
            child: AspectRatio(
              aspectRatio: 2 / 3, // Typical book cover ratio
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _bookDetails!.displayImageUrl != null
                      ? Image.network(
                          _bookDetails!.displayImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.book,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.book,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),

        // Back button overlay - positioned to match navigation bar exactly
        Positioned(
          top: MediaQuery.of(context).padding.top + (75 - 48) / 2, // Center vertically in 75px space
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent - shrinkOffset, child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
