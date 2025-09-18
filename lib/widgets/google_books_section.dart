import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import 'google_horizontal_book_card.dart';
import 'no_results_message.dart';

class GoogleBooksSection extends StatelessWidget {
  final List<BookSearchItem> books;
  final ScrollController scrollController;
  final String? selectedBookId;
  final void Function(BookSearchItem) onBookTap;

  const GoogleBooksSection({
    super.key,
    required this.books,
    required this.scrollController,
    required this.selectedBookId,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;
        
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
'${l10n['google_books']} (${books.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: books.isEmpty
              ? NoResultsMessage(
                  title: l10n['no_books_found_google'],
                  subtitle: l10n['try_different_terms_or_database'],
                  backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                )
              : ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                    scrollbars: false,
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return SizedBox(
                        width: 170,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GoogleHorizontalBookCard(
                            book: book,
                            isSelected: selectedBookId == book.id,
                            onTap: () => onBookTap(book),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
        );
      },
    );
  }
}