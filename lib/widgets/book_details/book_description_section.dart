import 'package:flutter/material.dart';
import '../../models/curated_collection_models.dart';

/// Widget for displaying book description
class BookDescriptionSection extends StatelessWidget {
  final CuratedCollectionItem collectionItem;

  const BookDescriptionSection({
    super.key,
    required this.collectionItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = collectionItem.book;

    if (book.description == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          book.description!,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}