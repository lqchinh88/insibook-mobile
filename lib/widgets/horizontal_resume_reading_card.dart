import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../screens/book_details_screen.dart';
import 'star_rating.dart';
import 'bookmark_button.dart';
import 'cached_image.dart';

class HorizontalResumeReadingCard extends StatelessWidget {
  final InternalBookItem book;
  final ReadingProgress readingProgress;

  const HorizontalResumeReadingCard({
    super.key,
    required this.book,
    required this.readingProgress,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = readingProgress.readingPercentage;

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Book cover with shadow
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  children: [
                    Container(
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
                        child: book.displayImageUrl != null
                            ? CachedImage(
                                imageUrl: book.displayImageUrl!,
                                fit: BoxFit.fitHeight,
                                errorWidget: _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),

                    // Bookmark button
                    if (book.isBookmarked != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: BookmarkButton(
                          bookId: book.id,
                          initialBookmarkState: book.isBookmarked!,
                          size: BookmarkButtonSize.small,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Progress bar with spacing
            Container(
              height: 8,
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Filled portion based on actual progress
                  Expanded(
                    flex: progressPercentage.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Empty portion (remaining percentage)
                  Expanded(
                    flex: 100 - progressPercentage.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Book info
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (book.authors.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        book.authors.first,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (book.hasGoodreadsData) ...[
                    const SizedBox(height: 2),
                    StarRating(
                      rating: book.goodreadsBook!.starRating,
                      reviewCount: book.goodreadsBook!.numReviews,
                      size: 12,
                      fontSize: 8,
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