import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../services/book_api_service.dart';
import 'summary_reader_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final InternalBookItem book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isLoading = true;
  BookWithSummary? _bookDetails;
  String? _errorMessage;
  String? _selectedSummaryLanguage;
  
  final List<Map<String, String>> _availableLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'vi', 'name': 'Tiếng Việt'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial summary language to app language
      final langProvider = context.read<LanguageProvider>();
      _selectedSummaryLanguage = langProvider.currentLanguage;
      _loadBookDetails();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize selected summary language to app language if not set
    if (_selectedSummaryLanguage == null) {
      final langProvider = context.read<LanguageProvider>();
      _selectedSummaryLanguage = langProvider.currentLanguage;
    }
  }

  Future<void> _loadBookDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await BookApiService.getBookWithSummary(
        bookId: widget.book.id,
        summaryLanguage: _selectedSummaryLanguage ?? 'en',
      );

      if (result != null) {
        setState(() {
          _bookDetails = BookWithSummary.fromJson(result);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load book details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading book details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _regenerateSummary() async {
    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<LanguageProvider>(
                builder: (context, langProvider, child) => Text(
                  langProvider.l10n['regenerating_summary'],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );

      // Call the backend API to regenerate summary
      final result = await BookApiService.generateSummaryAsync(
        googleBookId: widget.book.googleBookId,
        title: widget.book.title,
        authors: widget.book.authors,
        bookLanguage: widget.book.language,
        googleBookCoverImageUrl: widget.book.displayImageUrl,
        publisher: widget.book.publisher,
        industryIdentifiers: widget.book.industryIdentifiers,
        categories: widget.book.categories.map((c) => c.name).toList(),
      );

      if (result != null) {
        // Success - show job details
        final jobId = result['jobId'] ?? 'Unknown';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Summary regeneration started! Job ID: $jobId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Refresh',
              textColor: Colors.white,
              onPressed: () {
                // Reload book details to get the new summary
                _loadBookDetails();
              },
            ),
          ),
        );
        }
      } else {
        // Error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Consumer<LanguageProvider>(
              builder: (context, langProvider, child) => Text(
                langProvider.l10n['failed_to_generate'],
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        }
      }
    } catch (e) {
      // Exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, langProvider, child) => Text(
            langProvider.l10n['book_details'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: _isLoading
          ? Center(
              child: Consumer<LanguageProvider>(
                builder: (context, langProvider, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(langProvider.l10n['loading_book_details']),
                  ],
                ),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Consumer<LanguageProvider>(
                    builder: (context, langProvider, child) => ElevatedButton(
                      onPressed: _loadBookDetails,
                      child: Text(langProvider.l10n['retry']),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book header with cover and basic info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Book cover
                        Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: _bookDetails!.displayImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _bookDetails!.displayImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[300],
                                        ),
                                        child: const Icon(
                                          Icons.book,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 20),

                        // Book info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                _bookDetails!.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Subtitle
                              if (_bookDetails!.subtitle != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _bookDetails!.subtitle!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],

                              // Authors
                              if (_bookDetails!.authors.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'by ${_bookDetails!.authors.join(', ')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],

                              // Publisher and date
                              if (_bookDetails!.publisher != null ||
                                  _bookDetails!.publishedDate != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  [
                                    if (_bookDetails!.publisher != null)
                                      _bookDetails!.publisher,
                                    if (_bookDetails!.publishedDate != null)
                                      _bookDetails!.publishedDate,
                                  ].join(' • '),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],

                              // Page count and language
                              const SizedBox(height: 8),
                              Text(
                                [
                                  if (_bookDetails!.pageCount != null)
                                    '${_bookDetails!.pageCount} pages',
                                  'Language: ${_bookDetails!.language}',
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),

                              // Summary count badge
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.summarize,
                                      size: 16,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_bookDetails!.summaryCount} summary${_bookDetails!.summaryCount != 1 ? 'ies' : ''} available',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Categories section
                  if (_bookDetails!.categories.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, langProvider, child) => Text(
                              langProvider.l10n['categories'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
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
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Language selector for summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, langProvider, child) => Text(
                            langProvider.l10n['summary_language'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSummaryLanguage,
                              isExpanded: true,
                              icon: const Icon(Icons.language),
                              items: _availableLanguages.map((lang) {
                                return DropdownMenuItem<String>(
                                  value: lang['code'],
                                  child: Text(lang['name']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null && newValue != _selectedSummaryLanguage) {
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
                  const SizedBox(height: 20),

                  // Description section
                  if (_bookDetails!.description != null &&
                      _bookDetails!.description!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, langProvider, child) => Text(
                              langProvider.l10n['about_this_book'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _bookDetails!.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Introduction section
                  if (_bookDetails!.summary.introduction != null &&
                      _bookDetails!.summary.introduction!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, langProvider, child) => Text(
                              langProvider.l10n['introduction'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: MarkdownWidget(
                              data: _bookDetails!.summary.introduction!,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action buttons row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Read Summary button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SummaryReaderScreen(
                                      bookDetails: _bookDetails!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.menu_book, size: 24),
                              label: Consumer<LanguageProvider>(
                                builder: (context, langProvider, child) => Text(
                                  langProvider.l10n['read_summary'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Regenerate Summary button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _regenerateSummary,
                              icon: const Icon(Icons.refresh, size: 24),
                              label: Consumer<LanguageProvider>(
                                builder: (context, langProvider, child) => Text(
                                  langProvider.l10n['regenerate_summary'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
