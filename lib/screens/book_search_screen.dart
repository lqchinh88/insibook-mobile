import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../providers/book_api_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/internal_books_section.dart';
import '../widgets/google_books_section.dart';

class BookSearchScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialAuthor;

  const BookSearchScreen({super.key, this.initialTitle, this.initialAuthor});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _authorFocusNode = FocusNode();
  final ScrollController _internalScrollController = ScrollController();
  final ScrollController _googleScrollController = ScrollController();
  final GlobalKey _googleBookDetailsKey = GlobalKey();

  late final BookApiService _bookApiService;
  List<InternalBookItem> _internalBooks = [];
  List<BookSearchItem> _googleBooks = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Pagination variables
  int _internalOffset = 0;
  bool _hasMoreInternal = true;
  bool _isLoadingMore = false;
  BookSearchItem? _selectedGoogleBook;
  bool _isGeneratingSummary = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _bookApiService = context.read<BookApiProvider>().bookApiService;


    // Initialize controllers with provided values
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialAuthor != null) {
      _authorController.text = widget.initialAuthor!;
    }

    // Add scroll listener for internal books pagination
    _internalScrollController.addListener(_onInternalScroll);

    // Trigger search if initial values are provided
    if (widget.initialTitle != null || widget.initialAuthor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchBooks();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _titleFocusNode.dispose();
    _authorFocusNode.dispose();
    _internalScrollController.dispose();
    _googleScrollController.dispose();
    super.dispose();
  }

  void _onInternalScroll() {
    if (_internalScrollController.position.pixels >=
        _internalScrollController.position.maxScrollExtent - 200) {
      if (_hasMoreInternal && !_isLoadingMore) {
        _loadMoreInternal();
      }
    }
  }


  Future<void> _searchBooks() async {
    final l10n = context.read<LanguageProvider>().l10n;
    if (_titleController.text.trim().isEmpty &&
        _authorController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = l10n['please_enter_search'];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _internalOffset = 0;
      _hasMoreInternal = true;
      // Clear previous search results
      _internalBooks.clear();
      _googleBooks.clear();
      _selectedGoogleBook = null;
      _isGeneratingSummary = false;
    });

    // Reset scroll positions
    if (_internalScrollController.hasClients) {
      _internalScrollController.jumpTo(0);
    }
    if (_googleScrollController.hasClients) {
      _googleScrollController.jumpTo(0);
    }

    final titleQuery = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : null;
    final authorQuery = _authorController.text.trim().isNotEmpty
        ? _authorController.text.trim()
        : null;

    // Run both searches simultaneously
    final futures = [
      _searchInternal(titleQuery, authorQuery),
      _searchGoogle(titleQuery, authorQuery),
    ];

    await Future.wait(futures);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _searchInternal(String? title, String? author) async {
    final internalResult = await _bookApiService.searchInternalBooks(
      title: title,
      author: author,
      limit: 20,
      offset: 0,
    );

    if (mounted) {
      internalResult.fold(
        (response) {
          setState(() {
            _internalBooks = response.books;
            _hasMoreInternal = response.books.length == 20;
          });
        },
        (error) {
          setState(() {
            _errorMessage = error.userFriendlyMessage;
          });
        },
      );
    }
  }

  Future<void> _searchGoogle(String? title, String? author) async {
    final googleResult = await _bookApiService.searchGoogleBooks(
      title: title,
      author: author,
      maxResults: 20,
      startIndex: 0,
    );

    if (mounted) {
      googleResult.fold(
        (response) {
          setState(() {
            _googleBooks = response.items;
          });
        },
        (error) {
          setState(() {
            _errorMessage = error.userFriendlyMessage;
          });
        },
      );
    }
  }

  Future<void> _loadMoreInternal() async {
    if (_isLoadingMore || !_hasMoreInternal) return;

    setState(() {
      _isLoadingMore = true;
    });

    _internalOffset += 20;
    final internalResult = await _bookApiService.searchInternalBooks(
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
      author: _authorController.text.trim().isNotEmpty
          ? _authorController.text.trim()
          : null,
      limit: 20,
      offset: _internalOffset,
    );

    setState(() {
      internalResult.fold(
        (response) {
          _internalBooks.addAll(response.books);
          _hasMoreInternal = response.books.length == 20;
        },
        (error) {
          _errorMessage = error.userFriendlyMessage;
        },
      );
      _isLoadingMore = false;
    });
  }

  void _onGoogleBookTap(BookSearchItem book) {
    final wasSelected = _selectedGoogleBook?.id == book.id;

    setState(() {
      _selectedGoogleBook = wasSelected ? null : book;
    });

    // Scroll to show the expanded box only if we're selecting a book (not deselecting)
    if (!wasSelected && _selectedGoogleBook != null) {
      _scrollToGoogleBookDetails();
    }
  }

  void _scrollToGoogleBookDetails() {
    // Use WidgetsBinding to ensure proper timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyContext = _googleBookDetailsKey.currentContext;
      if (keyContext == null) return;

      try {
        // Use Scrollable.ensureVisible - more reliable than manual controller manipulation
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Show at 10% from top of screen
        );
      } catch (e) {
        // Silently handle any scroll errors
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _titleController.clear();
      _authorController.clear();
      _internalBooks.clear();
      _googleBooks.clear();
      _hasSearched = false;
      _errorMessage = null;
      _internalOffset = 0;
      _hasMoreInternal = true;
      _selectedGoogleBook = null;
      _isGeneratingSummary = false;
    });

    // Reset scroll positions
    if (_internalScrollController.hasClients) {
      _internalScrollController.jumpTo(0);
    }
    if (_googleScrollController.hasClients) {
      _googleScrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, langProvider, child) => Text(
            langProvider.l10n['book_search'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (_hasSearched)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear search',
            ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Consumer<LanguageProvider>(
                  builder: (context, langProvider, child) => Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(
                          labelText: langProvider.l10n['book_title'],
                          hintText: langProvider.l10n['book_title'],
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        onSubmitted: (_) => _searchBooks(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _authorController,
                        focusNode: _authorFocusNode,
                        decoration: InputDecoration(
                          labelText: langProvider.l10n['author_optional'],
                          hintText: langProvider.l10n['author_optional'],
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        onSubmitted: (_) => _searchBooks(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _searchBooks,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  langProvider.l10n['search_books'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildResultsBody(),
      ),
    );
  }

  Widget _buildResultsBody() {
    if (!_hasSearched) {
      return Consumer<LanguageProvider>(
        builder: (context, langProvider, child) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                langProvider.l10n['start_your_search'] ?? 'Start your search',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                langProvider.l10n['enter_book_title_author_begin'] ?? 'Enter a book title or author to begin',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching both databases...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Internal Books Section - Always show after search
          InternalBooksSection(
            books: _internalBooks,
            isLoadingMore: _isLoadingMore,
            scrollController: _internalScrollController,
          ),

          // Google Books Section - Always show after search
          GoogleBooksSection(
            books: _googleBooks,
            scrollController: _googleScrollController,
            selectedBookId: _selectedGoogleBook?.id,
            onBookTap: _onGoogleBookTap,
          ),

          // Selected Google Book Details
          if (_selectedGoogleBook != null)
            Container(
              key: _googleBookDetailsKey,
              child: _buildGoogleBookDetails(_selectedGoogleBook!),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGoogleBookDetails(BookSearchItem book) {
    final l10n = context.read<LanguageProvider>().l10n;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: book.imageUrl != null
                      ? Image.network(
                          _getProxiedImageUrl(book.imageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.book,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.book,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${book.authors.join(', ')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (book.publisher != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.publisher!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (book.publishedDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.publishedDate!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],

                    if (book.pageCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${book.pageCount} pages',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (book.description != null && book.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n['description'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book.description!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Summarise button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingSummary
                  ? null
                  : () => _summariseGoogleBook(book),
              icon: _isGeneratingSummary
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                _isGeneratingSummary
                    ? l10n['generating_summary']
                    : l10n['summarise_this_book'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGeneratingSummary
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Proxy Google Books images to bypass CORS restrictions
  String _getProxiedImageUrl(String url) {
    if (url.contains('books.google.com')) {
      String encodedUrl = Uri.encodeComponent(url);
      return 'https://images.weserv.nl/?url=$encodedUrl&w=160&h=240&fit=cover';
    }
    return url;
  }

  Future<void> _summariseGoogleBook(BookSearchItem book) async {
    if (_isGeneratingSummary) return;

    setState(() {
      _isGeneratingSummary = true;
    });

    final result = await _bookApiService.generateSummaryAsync(
      googleBookId: book.id,
      title: book.title,
      authors: book.authors,
      bookLanguage: book.language ?? 'en',
      googleBookCoverImageUrl: book.imageUrl,
      publisher: book.publisher,
      industryIdentifiers: book.industryIdentifiers,
      categories: book.categories,
    );

    if (mounted) {
      result.fold(
        (response) {
          setState(() {
            _isGeneratingSummary = false;
            _selectedGoogleBook =
                null; // Close the expanded box after successful submission
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Summary generation started for "${book.title}". You can check progress in your library.',
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 4),
            ),
          );
        },
        (error) {
          setState(() {
            _isGeneratingSummary = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to start summary generation for "${book.title}": ${error.userFriendlyMessage}',
              ),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    }
  }
}
