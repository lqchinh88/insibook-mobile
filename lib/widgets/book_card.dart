import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../services/book_api_service.dart';
import '../screens/book_details_screen.dart';

class InternalBookCard extends StatelessWidget {
  final InternalBookItem book;

  const InternalBookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover image
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: book.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[300],
                              ),
                              child: const Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: const Icon(
                          Icons.book,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle
                    if (book.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Authors
                    if (book.authors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'by ${book.authors.join(', ')}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Publisher and date
                    if (book.publisher != null ||
                        book.publishedDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (book.publisher != null) book.publisher,
                          if (book.publishedDate != null) book.publishedDate,
                        ].join(' • '),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],

                    // Categories
                    if (book.categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: book.categories.take(3).map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Summary count badge
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.summarize,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${book.summaryCount} summary${book.summaryCount != 1 ? 'ies' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon to indicate it's tappable
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleBookCard extends StatefulWidget {
  final BookSearchItem book;

  const GoogleBookCard({super.key, required this.book});

  @override
  State<GoogleBookCard> createState() => _GoogleBookCardState();
}

class _GoogleBookCardState extends State<GoogleBookCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _proxyByPassGoogleIfNeeded(String url) {
    // Use a proxy service to bypass CORS restrictions for Google Books images
    if (url.contains('books.google.com')) {
      // Use images.weserv.nl as a proxy to bypass CORS
      String encodedUrl = Uri.encodeComponent(url);
      return 'https://images.weserv.nl/?url=$encodedUrl&w=160&h=240&fit=cover';
    }

    return url;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _summariseBook() async {
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
              const Text('Generating summary...'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );

      // Call the backend API
      final result = await BookApiService.generateSummaryAsync(
        googleBookId: widget.book.id,
        title: widget.book.title,
        authors: widget.book.authors,
        language: widget.book.language ?? 'en',
      );

      if (result != null) {
        // Success - show job details
        final jobId = result['jobId'] ?? 'Unknown';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Summary generation started! Job ID: $jobId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View Status',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to job status page or show job details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Job status: ${result['status'] ?? 'Processing'}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to start summary generation. Please try again.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main book info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover image
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: widget.book.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _proxyByPassGoogleIfNeeded(widget.book.imageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(
                              Icons.book,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Book details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Authors
                        if (widget.book.authors.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'by ${widget.book.authors.join(', ')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Published date and page count
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (widget.book.publishedDate != null &&
                                widget.book.publishedDate!.isNotEmpty)
                              widget.book.publishedDate,
                            if (widget.book.pageCount > 0)
                              '${widget.book.pageCount} pages',
                            if (widget.book.language != null)
                              widget.book.language,
                          ].join(' • '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        // Categories
                        if (widget.book.categories.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: widget.book.categories.take(3).map((
                              category,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Google Books badge
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search,
                                size: 14,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Google Books',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),

              // Expanded content
              SizeTransition(
                sizeFactor: _animation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Full description
                    if (widget.book.description != null &&
                        widget.book.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.book.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Book details section
                    Text(
                      'Book Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Title', widget.book.title),
                    if (widget.book.authors.isNotEmpty)
                      _buildDetailRow(
                        'Authors',
                        widget.book.authors.join(', '),
                      ),
                    if (widget.book.publishedDate != null &&
                        widget.book.publishedDate!.isNotEmpty)
                      _buildDetailRow('Published', widget.book.publishedDate!),
                    if (widget.book.pageCount > 0)
                      _buildDetailRow('Pages', '${widget.book.pageCount}'),
                    if (widget.book.language != null)
                      _buildDetailRow('Language', widget.book.language!),
                    if (widget.book.categories.isNotEmpty)
                      _buildDetailRow(
                        'Categories',
                        widget.book.categories.join(', '),
                      ),

                    const SizedBox(height: 16),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _summariseBook,
                        icon: const Icon(Icons.summarize),
                        label: const Text('Summarise this book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
