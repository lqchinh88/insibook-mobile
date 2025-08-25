import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/book_models.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Google Books (${books.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: books.isEmpty
              ? const NoResultsMessage(
                  title: 'No books found in Google Books',
                  subtitle: 'Try different search terms or browse our database above',
                  backgroundColor: Color(0xFFFFF3E0),
                  borderColor: Color(0xFFFFCC80),
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
                        width: 200,
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
  }
}