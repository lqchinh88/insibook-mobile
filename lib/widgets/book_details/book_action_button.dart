import 'package:flutter/material.dart';
import '../../models/curated_collection_models.dart';
import '../../providers/language_provider.dart';
import '../../screens/book_details_screen.dart';
import 'package:provider/provider.dart';

/// Widget for the book action button (Read Summary)
class BookActionButton extends StatelessWidget {
  final CuratedCollectionItem collectionItem;

  const BookActionButton({
    super.key,
    required this.collectionItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = collectionItem.book;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to book details screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(
                book: book,
              ),
            ),
          );
        },
        icon: const Icon(Icons.menu_book_rounded, size: 18),
        label: Text(context.read<LanguageProvider>().l10n['read_summary']),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 6,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}