import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../screens/book_details_screen.dart';
import 'star_rating.dart';
import 'bookmark_button.dart';

class HorizontalResumeReadingCard extends StatelessWidget {
  final ResumeReadingBook resumeReadingBook;

  const HorizontalResumeReadingCard({
    super.key,
    required this.resumeReadingBook,
  });

  @override
  Widget build(BuildContext context) {
    final book = resumeReadingBook.book;
    final progressPercentage = resumeReadingBook.readingPercentage;

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
            // Book cover with shadow and progress bar
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
                        child: Stack(
                          children: [
                            // Book cover image
                            book.displayImageUrl != null
                                ? Image.network(
                                    book.displayImageUrl!,
                                    fit: BoxFit.fitHeight,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),

                            // Progress bar at the bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  ),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progressPercentage / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

                    // Progress percentage indicator
                    Positioned(
                      bottom: 8,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${progressPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  // Reading time info
                  const SizedBox(height: 2),
                  Text(
                    '${resumeReadingBook.totalTimeSpentMinutes.toInt()} min read',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 8,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
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