import 'package:flutter/material.dart';
import '../models/book_models.dart';

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
    final timeSpent = resumeReadingBook.totalTimeSpentMinutes;
    final lastRead = resumeReadingBook.lastReadAt;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.displayImageUrl != null
                    ? Image.network(
                        book.displayImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.book_outlined,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.book_outlined,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (book.authors.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.authors.first,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 6),

                // Progress bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Progress info
                Row(
                  children: [
                    Text(
                      '${progressPercentage.toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeSpent.toInt()}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),

                // Last read time
                Text(
                  _formatLastRead(lastRead),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 9,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastRead(DateTime lastRead) {
    final now = DateTime.now();
    final difference = now.difference(lastRead);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Simple date formatting without intl
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[lastRead.month - 1]} ${lastRead.day}';
    }
  }
}