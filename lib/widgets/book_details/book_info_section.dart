import 'package:flutter/material.dart';
import '../../models/curated_collection_models.dart';

/// Widget for displaying basic book information (title, author, rating)
class BookInfoSection extends StatelessWidget {
  final CuratedCollectionItem collectionItem;

  const BookInfoSection({
    super.key,
    required this.collectionItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = collectionItem.book;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book title
        Text(
          book.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // Author
        Text(
          'by ${book.authors.join(', ')}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 16),

        // Decorative divider
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 20),

        // Rating if available
        if (book.goodreadsBook != null) ...[
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${book.goodreadsBook!.starRating.toStringAsFixed(1)} / 5.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${book.goodreadsBook!.numRatings} ratings)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}