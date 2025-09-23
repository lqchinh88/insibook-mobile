import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import 'star_rating_display.dart';

class HeroBookCard extends StatelessWidget {
  final InternalBookItem? book;
  final String? imageUrl;
  final String? ctaText;
  final VoidCallback? onReadSummary;

  const HeroBookCard({
    super.key,
    this.book,
    this.imageUrl,
    this.ctaText,
    this.onReadSummary,
  });

  @override
  Widget build(BuildContext context) {
    final bookTitle = book?.title ?? 'The Midnight Library';
    final bookAuthor = book?.authors.isNotEmpty == true ? book!.authors.first : 'Matt Haig';
    final bookImage = book?.imageUrl ?? imageUrl ?? '';

    // Get Goodreads rating data
    final goodreadsBook = book?.goodreadsBook;
    final hasGoodreadsData = goodreadsBook != null && goodreadsBook.starRating > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F2937), // Dark gray-blue
            Color(0xFF374151), // Medium gray
            Color(0xFFF9FAFB), // Very light gray
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
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      final l10n = languageProvider.l10n;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n['book_of_the_day'] as String? ?? 'Book of the Day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Book Title
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Goodreads Rating or fallback
                  if (hasGoodreadsData)
                    StarRatingDisplay(
                      rating: goodreadsBook.starRating,
                      reviewCount: goodreadsBook.numRatings,
                      starSize: 14,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      'One library. Infinite possibilities.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, child) {
                        final l10n = languageProvider.l10n;
                        final buttonText = ctaText ?? (l10n['read_summary'] as String? ?? 'Read');

                        return ElevatedButton(
                          onPressed: onReadSummary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
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
                        );
                      },
                    ),
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