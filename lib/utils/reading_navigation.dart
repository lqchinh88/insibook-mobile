import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../screens/book_content_screen.dart';
import '../screens/chapter_reading_screen.dart';

class ReadingNavigation {
  static void navigateToReadingScreen(
    BuildContext context, {
    required BookWithContent book,
    SummaryChapter? chapter,
  }) {
    if (book.summary.chapters.isNotEmpty) {
      // Use new chapter-based reading screen for books with chapters
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterReadingScreen(book: book, initialChapter: chapter),
        ),
      );
    } else {
      // Use existing reading screen for books without chapters
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookContentScreen(bookContent: book),
        ),
      );
    }
  }

  static void navigateToReadingScreenAndReplace(
    BuildContext context, {
    required BookWithContent book,
  }) {
    if (book.summary.chapters.isNotEmpty) {
      // Use new chapter-based reading screen for books with chapters
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterReadingScreen(book: book),
        ),
      );
    } else {
      // Use existing reading screen for books without chapters
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookContentScreen(bookContent: book),
        ),
      );
    }
  }
}