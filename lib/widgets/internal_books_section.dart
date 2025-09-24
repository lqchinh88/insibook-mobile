import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import 'horizontal_book_card.dart';
import 'no_results_message.dart';

class InternalBooksSection extends StatelessWidget {
  final List<InternalBookItem> books;
  final bool isLoadingMore;
  final bool isLoading;
  final ScrollController scrollController;

  const InternalBooksSection({
    super.key,
    required this.books,
    required this.isLoadingMore,
    required this.isLoading,
    required this.scrollController,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n['our_database']} (${books.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (isLoadingMore)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : books.isEmpty
              ? NoResultsMessage(
                  title: l10n['no_books_found_internal'],
                  subtitle: l10n['try_different_terms_or_google'],
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                    itemCount: books.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == books.length && isLoadingMore) {
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: HorizontalBookCard(book: books[index]),
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