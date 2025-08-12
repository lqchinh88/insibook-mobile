import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../services/book_api_service.dart';
import '../widgets/book_card.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

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

    try {
      // First, search internal database
      final internalResponse = await BookApiService.searchInternalBooks(
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        author: _authorController.text.trim().isNotEmpty
            ? _authorController.text.trim()
            : null,
        limit: 20,
        offset: 0,
      );

      setState(() {
        _internalBooks = internalResponse?.books ?? [];
        _isLoading = false;
        _hasMoreInternal = (internalResponse?.books.length ?? 0) == 20;

        // Always show Google suggestion
        _showGoogleSuggestion = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error searching books: $e';
      });
    }
  }

  Future<void> _searchGoogleBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _googleStartIndex = 0;
      _hasMoreGoogle = true;
    });

    try {
      final googleResponse = await BookApiService.searchGoogleBooks(
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        author: _authorController.text.trim().isNotEmpty
            ? _authorController.text.trim()
            : null,
        maxResults: 20,
        startIndex: 0,
      );

      setState(() {
        _googleBooks = googleResponse?.items ?? [];
        _isLoading = false;
        _showGoogleSuggestion = false;
        _hasMoreGoogle = (googleResponse?.items.length ?? 0) == 20;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error searching Google Books: $e';
      });
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
              'Search for books by title or author',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
            Text('Searching for books...'),
          ],
        ),
      );
    }

    final allBooks = <Widget>[];

    // Add internal books
    if (_internalBooks.isNotEmpty) {
      allBooks.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${_internalBooks.length} book(s) in our database',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      );

      for (final book in _internalBooks) {
        allBooks.add(InternalBookCard(book: book));
      }

      // Add load more button for internal books
      if (_hasMoreInternal) {
        allBooks.add(
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingMore ? null : _loadMoreInternal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Load More Internal Books'),
              ),
            ),
          ),
        );
      }
    }

    // Add Google suggestion (always show after internal results)
    if (_showGoogleSuggestion && _hasSearched && !_isLoading) {
      allBooks.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.search, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _internalBooks.isEmpty
                          ? 'No books found in our database'
                          : 'Not what you\'re looking for?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching Google Books for more results',
                style: TextStyle(color: Colors.orange[600]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchGoogleBooks,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Google Books'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add Google books
    if (_googleBooks.isNotEmpty) {
      allBooks.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${_googleBooks.length} book(s) on Google Books',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      );

      for (final book in _googleBooks) {
        allBooks.add(GoogleBookCard(book: book));
      }

      // Add load more button for Google books
      if (_hasMoreGoogle) {
        allBooks.add(
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingMore ? null : _loadMoreGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[100],
                  foregroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Load More Google Books'),
              ),
            ),
          ),
        );
      }
    }

    if (allBooks.isEmpty && _hasSearched && !_isLoading) {
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

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: allBooks.length,
      itemBuilder: (context, index) => allBooks[index],
    );
  }
}
