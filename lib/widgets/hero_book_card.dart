import 'package:flutter/material.dart';
import '../models/book_models.dart';

class HeroBookCard extends StatelessWidget {
  final InternalBookItem? book;
  final String? imageUrl;
  final String? ctaText;
  final VoidCallback? onReadSummary;
  final VoidCallback? onBookmark;

  const HeroBookCard({
    super.key,
    this.book,
    this.imageUrl,
    this.ctaText,
    this.onReadSummary,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final bookTitle = book?.title ?? 'The Midnight Library';
    final bookAuthor = book?.authors.isNotEmpty == true ? book!.authors.first : 'Matt Haig';
    final bookImage = book?.imageUrl ?? imageUrl ?? '';
    final tagline = book?.description?.split('.').first ?? 'One library. Infinite possibilities.';
    final buttonText = ctaText ?? 'Read Summary';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B5A), // Orange-red
            Color(0xFFFFB347), // Orange
            Color(0xFFF5E6D3), // Beige
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Book Cover (35-40% width)
            Expanded(
              flex: 38,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: bookImage.isNotEmpty
                      ? Image.network(
                          bookImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderCover(bookTitle),
                        )
                      : _buildPlaceholderCover(bookTitle),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Book Information (60-65% width)
            Expanded(
              flex: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pill-shaped label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B5A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Book of the Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Book Title
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Author Name
                  Text(
                    bookAuthor,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    tagline,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      // Primary Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReadSummary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B5A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bookmark Button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: onBookmark,
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Color(0xFF2C3E50),
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}