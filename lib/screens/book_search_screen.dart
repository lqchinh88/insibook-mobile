import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/book_card.dart';
import '../widgets/horizontal_book_card.dart';
import '../widgets/google_horizontal_book_card.dart';

class BookSearchScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialAuthor;
  
  const BookSearchScreen({
    super.key,
    this.initialTitle,
    this.initialAuthor,
  });

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _authorFocusNode = FocusNode();

  List<InternalBookItem> _internalBooks = [];
  List<BookSearchItem> _googleBooks = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _showGoogleSuggestion = false;
  String? _errorMessage;

  // Pagination variables
  int _internalOffset = 0;
  int _googleStartIndex = 0;
  bool _hasMoreInternal = true;
  bool _hasMoreGoogle = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with provided values
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialAuthor != null) {
      _authorController.text = widget.initialAuthor!;
    }
    
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
    super.dispose();
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
      _showGoogleSuggestion = false;
      _internalOffset = 0;
      _googleStartIndex = 0;
      _hasMoreInternal = true;
      _hasMoreGoogle = true;
      // Clear previous search results
      _internalBooks.clear();
      _googleBooks.clear();
    });

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
    try {
      final internalResponse = await BookApiService.searchInternalBooks(
        title: title,
        author: author,
        limit: 20,
        offset: 0,
      );

      if (mounted) {
        setState(() {
          _internalBooks = internalResponse?.books ?? [];
          _hasMoreInternal = (internalResponse?.books.length ?? 0) == 20;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error searching internal books: $e';
        });
      }
    }
  }

  Future<void> _searchGoogle(String? title, String? author) async {
    try {
      final googleResponse = await BookApiService.searchGoogleBooks(
        title: title,
        author: author,
        maxResults: 20,
        startIndex: 0,
      );

      if (mounted) {
        setState(() {
          _googleBooks = googleResponse?.items ?? [];
          _showGoogleSuggestion = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_errorMessage == null) {
            _errorMessage = 'Error searching Google books: $e';
          }
        });
      }
    }
  }


  Future<void> _loadMoreInternal() async {
    if (_isLoadingMore || !_hasMoreInternal) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _internalOffset += 20;
      final internalResponse = await BookApiService.searchInternalBooks(
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
        _internalBooks.addAll(internalResponse?.books ?? []);
        _hasMoreInternal = (internalResponse?.books.length ?? 0) == 20;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _errorMessage = 'Error loading more books: $e';
      });
    }
  }

  Future<void> _loadMoreGoogle() async {
    if (_isLoadingMore || !_hasMoreGoogle) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _googleStartIndex += 20;
      final googleResponse = await BookApiService.searchGoogleBooks(
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        author: _authorController.text.trim().isNotEmpty
            ? _authorController.text.trim()
            : null,
        maxResults: 20,
        startIndex: _googleStartIndex,
      );

      setState(() {
        _googleBooks.addAll(googleResponse?.items ?? []);
        _hasMoreGoogle = (googleResponse?.items.length ?? 0) == 20;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _errorMessage = 'Error loading more books: $e';
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _titleController.clear();
      _authorController.clear();
      _internalBooks.clear();
      _googleBooks.clear();
      _hasSearched = false;
      _showGoogleSuggestion = false;
      _errorMessage = null;
      _internalOffset = 0;
      _googleStartIndex = 0;
      _hasMoreInternal = true;
      _hasMoreGoogle = true;
    });
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
          // Language Dropdown
          Consumer<LanguageProvider>(
            builder: (context, langProvider, child) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                value: langProvider.currentLanguage,
                underline: Container(),
                icon: const Icon(Icons.language, color: Colors.blue),
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'vi',
                    child: Text('Tiếng Việt'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    langProvider.setLanguage(newValue);
                  }
                },
              ),
            ),
          ),
          if (_hasSearched)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear search',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Form
          Container(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

          // Error Message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Start your search',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Enter a book title or author to begin',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
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

    if (_internalBooks.isEmpty && _googleBooks.isEmpty && _hasSearched && !_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try different search terms',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Internal Books Section
          if (_internalBooks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Database (${_internalBooks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (_hasMoreInternal)
                    TextButton(
                      onPressed: _isLoadingMore ? null : _loadMoreInternal,
                      child: _isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load More'),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _internalBooks.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: HorizontalBookCard(book: _internalBooks[index]),
                    ),
                  );
                },
              ),
            ),
          ],

          // Google Books Section
          if (_googleBooks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Google Books (${_googleBooks.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _googleBooks.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GoogleHorizontalBookCard(book: _googleBooks[index]),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
