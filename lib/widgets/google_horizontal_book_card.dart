import 'package:flutter/material.dart';
import '../models/book_models.dart';

class GoogleHorizontalBookCard extends StatelessWidget {
  final BookSearchItem book;
  final VoidCallback? onTap;
  final bool isSelected;

  const GoogleHorizontalBookCard({
    super.key, 
    required this.book,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: isSelected ? BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
      ) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Book cover with shadow
            Expanded(
              flex: 3,
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
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
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            // Book stand base
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Book info
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (book.authors.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.authors.first,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Proxy Google Books images to bypass CORS restrictions
  String _getProxiedImageUrl(String url) {
    // Use a proxy service to bypass CORS restrictions for Google Books images
    if (url.contains('books.google.com')) {
      // Use images.weserv.nl as a proxy to bypass CORS
      String encodedUrl = Uri.encodeComponent(url);
      return 'https://images.weserv.nl/?url=$encodedUrl&w=160&h=240&fit=cover';
    }
    return url;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.book,
          size: 24,
          color: Colors.grey,
        ),
      ),
    );
  }
}