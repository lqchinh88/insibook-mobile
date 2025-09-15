import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
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

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late final BookApiService _bookApiService;
  BookWithContent? _bookDetails;
  bool _isLoading = false;
  bool _hasError = false;
  String? _selectedSummaryLanguage;
  final ScrollController _scrollController = ScrollController();
  double _coverOffset = 0.0;
  bool _isIntroductionExpanded = false;

  final List<Map<String, String>> _availableLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'vi', 'name': 'Tiếng Việt'},
  ];

  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial summary language to app language
      final langProvider = context.read<LanguageProvider>();
      _selectedSummaryLanguage = langProvider.currentLanguage;
      _loadBookDetails();
    });
    _scrollController.addListener(_updateCoverOffset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCoverOffset);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCoverOffset() {
    setState(() {
      _coverOffset = _scrollController.offset;
    });
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
                ElevatedButton(
                  onPressed: _loadBookDetails,
                  child: Text(langProvider.l10n['retry'] ?? 'Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(body: _buildParallaxLayout());
  }

  // Helper method to check if there's more content to show
  bool get _hasMoreContent {
    final introduction = _bookDetails!.summary.introduction!;
    // Consider content longer than ~300 characters as "more content"
    return introduction.length > 300;
  }

  // Helper method to build introduction preview
  Widget _buildIntroductionPreview() {
    final introduction = _bookDetails!.summary.introduction!;

    if (!_hasMoreContent || _isIntroductionExpanded) {
      // Show full content if it's short or expanded
      return MarkdownWidget(
        data: introduction,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    } else {
      // Show preview (first ~150 characters)
      final preview = introduction.length > 300
          ? '${introduction.substring(0, 300)}...'
          : introduction;

      return MarkdownWidget(
        data: preview,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }
  }

  Widget _buildParallaxLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    final coverHeight = screenHeight * 0.4;

    return Stack(
      children: [
        // Parallax cover layer (bottom layer)
        Positioned(
          top: -coverHeight * 0.3, // Start with some cover hidden above
          left: 0,
          right: 0,
          height:
              coverHeight *
              1.3, // Make cover taller to allow for parallax movement
          child: Transform.translate(
            offset: Offset(0, _coverOffset * 0.5),
            child: ClipRect(
              child: Container(
                height: coverHeight * 1.3,
                child: Transform.translate(
                  offset: Offset(0, -_coverOffset * 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: _bookDetails!.displayImageUrl != null
                        ? Image.network(
                            _bookDetails!.displayImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
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
                            decoration: BoxDecoration(color: Colors.grey[300]),
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
        ),

        // Scrollable content layer (top layer)
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top spacer for cover area
            SliverToBoxAdapter(child: SizedBox(height: coverHeight)),

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

                    const SizedBox(height: 24),

                    // Language selector
                    Consumer<LanguageProvider>(
                      builder: (context, langProvider, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.l10n['summary_language'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSummaryLanguage,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.language,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                items: _availableLanguages.map((lang) {
                                  return DropdownMenuItem<String>(
                                    value: lang['code'],
                                    child: Text(lang['name']!),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != _selectedSummaryLanguage) {
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

                    const SizedBox(height: 24),

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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 24),
                    ],

                    // Introduction section
                    if (_bookDetails!.summary.introduction != null &&
                        _bookDetails!.summary.introduction!.isNotEmpty) ...[
                      Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) => Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Always visible header
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  langProvider.l10n['introduction'] ??
                                      'Introduction',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),

                              // Preview content (always visible)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: _buildIntroductionPreview(),
                              ),

                              // Expand/Collapse button
                              if (_hasMoreContent)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isIntroductionExpanded =
                                          !_isIntroductionExpanded;

                                      // When collapsing, scroll to top to reset cover position
                                      if (!_isIntroductionExpanded) {
                                        _scrollController.animateTo(
                                          0,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    });
                                  },
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withValues(alpha: 0.5),
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isIntroductionExpanded
                                              ? 'Show less'
                                              : 'Show more',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _isIntroductionExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Read Summary button
                    if (_bookDetails!.summary.content != null ||
                        _bookDetails!.summary.chapters.isNotEmpty)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookContentScreen(
                                  bookContent: _bookDetails!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.book_outlined),
                          label: Consumer<LanguageProvider>(
                            builder: (context, langProvider, child) => Text(
                              langProvider.l10n['read_summary'] ??
                                  'Read Summary',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Back button overlay (top-most layer)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }
}
