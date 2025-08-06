import 'package:flutter/material.dart';
import '../models/book_models.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _titleFocusNode.dispose();
    _authorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    if (_titleController.text.trim().isEmpty &&
        _authorController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a title or author to search';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
      _showGoogleSuggestion = false;
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

        // Show Google suggestion if no internal results found
        if (_internalBooks.isEmpty) {
          _showGoogleSuggestion = true;
        }
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
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error searching Google Books: $e';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Book Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
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
      body: Column(
        children: [
          // Search Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Book Title',
                    hintText: 'Enter book title...',
                    prefixIcon: const Icon(Icons.book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _searchBooks(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _authorController,
                  focusNode: _authorFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Author (Optional)',
                    hintText: 'Enter author name...',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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
                        : const Text(
                            'Search Books',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),

          // Google Search Suggestion
          if (_showGoogleSuggestion)
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
                          'No books found in our database',
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
