import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:insibook_mobile/screens/book_search_screen.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/services/book_api_service.dart';
import 'package:insibook_mobile/models/book_models.dart';
import 'package:insibook_mobile/widgets/internal_books_section.dart';
import 'package:insibook_mobile/widgets/google_books_section.dart';
import 'package:insibook_mobile/widgets/no_results_message.dart';

import 'book_search_sections_test.mocks.dart';

@GenerateMocks([BookApiService])
void main() {
  group('BookSearchScreen - Always Show Both Sections Tests', () {
    late MockBookApiService mockBookApiService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockBookApiService = MockBookApiService();
    });

    tearDown(() {
      reset(mockBookApiService);
    });

    Widget createBookSearchScreen() {
      return ChangeNotifierProvider(
        create: (context) => LanguageProvider(),
        child: MaterialApp(
          home: BookSearchScreen(
            bookApiService: mockBookApiService,
          ),
        ),
      );
    }

    testWidgets('should always show both sections after search with results in both', (WidgetTester tester) async {
      // Mock successful responses for both internal and Google Books
      final internalResponse = InternalBookSearchResponse(
        books: [
          InternalBookItem(
            id: 'internal_1',
            googleBookId: 'google_internal_1',
            title: 'Test Internal Book',
            authors: ['Internal Author'],
            description: 'Test description',
            categories: [],
            language: 'en',
            imageUrl: 'https://example.com/cover.jpg',
            summaryCount: 1,
            createdAt: '2024-01-01T00:00:00.000Z',
            updatedAt: '2024-01-01T00:00:00.000Z',
          ),
        ],
        total: 1,
        count: 1,
        offset: 0,
      );
      
      final googleResponse = BookSearchResponse(
        items: [
          BookSearchItem(
            id: 'google_1',
            title: 'Test Google Book',
            authors: ['Google Author'],
            description: 'Test Google description',
            imageUrl: 'https://books.google.com/cover.jpg',
            pageCount: 200,
            publisher: 'Test Publisher',
            publishedDate: '2024',
            language: 'en',
            categories: ['Fiction'],
            industryIdentifiers: [],
          ),
        ],
        totalItems: 1,
      );
      
      when(mockBookApiService.searchInternalBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => internalResponse);
      
      when(mockBookApiService.searchGoogleBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        maxResults: anyNamed('maxResults'),
        startIndex: anyNamed('startIndex'),
      )).thenAnswer((_) async => googleResponse);

      await tester.pumpWidget(createBookSearchScreen());
      
      // Enter search terms
      await tester.enterText(find.byType(TextField).first, 'test book');
      
      // Tap search button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search Books'));
      await tester.pump();
      
      // Wait for search completion
      await tester.pumpAndSettle();

      // Should always show both sections
      expect(find.byType(InternalBooksSection), findsOneWidget);
      expect(find.byType(GoogleBooksSection), findsOneWidget);
      
      // Should show section headers
      expect(find.text('Our Database (1)'), findsOneWidget);
      expect(find.text('Google Books (1)'), findsOneWidget);
      
      // Should not show no results messages since both have results
      expect(find.byType(NoResultsMessage), findsNothing);
    });

    testWidgets('should show both sections with no results message when both are empty', (WidgetTester tester) async {
      // Mock empty responses for both internal and Google Books
      final emptyInternalResponse = InternalBookSearchResponse(
        books: [],
        total: 0,
        count: 0,
        offset: 0,
      );
      
      final emptyGoogleResponse = BookSearchResponse(
        items: [],
        totalItems: 0,
      );
      
      when(mockBookApiService.searchInternalBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => emptyInternalResponse);
      
      when(mockBookApiService.searchGoogleBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        maxResults: anyNamed('maxResults'),
        startIndex: anyNamed('startIndex'),
      )).thenAnswer((_) async => emptyGoogleResponse);

      await tester.pumpWidget(createBookSearchScreen());
      
      // Enter search terms
      await tester.enterText(find.byType(TextField).first, 'nonexistent book');
      
      // Tap search button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search Books'));
      await tester.pump();
      
      // Wait for search completion
      await tester.pumpAndSettle();

      // Should always show both sections
      expect(find.byType(InternalBooksSection), findsOneWidget);
      expect(find.byType(GoogleBooksSection), findsOneWidget);
      
      // Should show section headers with 0 count
      expect(find.text('Our Database (0)'), findsOneWidget);
      expect(find.text('Google Books (0)'), findsOneWidget);
      
      // Should show no results messages for both sections
      expect(find.byType(NoResultsMessage), findsNWidgets(2));
      expect(find.text('No books found in our database'), findsOneWidget);
      expect(find.text('No books found in Google Books'), findsOneWidget);
    });

    testWidgets('should show both sections when internal has results but Google is empty', (WidgetTester tester) async {
      // Mock internal results but empty Google response
      final internalResponse = InternalBookSearchResponse(
        books: [
          InternalBookItem(
            id: 'internal_1',
            googleBookId: 'google_internal_1',
            title: 'Test Internal Book',
            authors: ['Internal Author'],
            description: 'Test description',
            categories: [],
            language: 'en',
            imageUrl: 'https://example.com/cover.jpg',
            summaryCount: 1,
            createdAt: '2024-01-01T00:00:00.000Z',
            updatedAt: '2024-01-01T00:00:00.000Z',
          ),
        ],
        total: 1,
        count: 1,
        offset: 0,
      );
      
      final emptyGoogleResponse = BookSearchResponse(
        items: [],
        totalItems: 0,
      );
      
      when(mockBookApiService.searchInternalBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => internalResponse);
      
      when(mockBookApiService.searchGoogleBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        maxResults: anyNamed('maxResults'),
        startIndex: anyNamed('startIndex'),
      )).thenAnswer((_) async => emptyGoogleResponse);

      await tester.pumpWidget(createBookSearchScreen());
      
      // Enter search terms
      await tester.enterText(find.byType(TextField).first, 'internal only book');
      
      // Tap search button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search Books'));
      await tester.pump();
      
      // Wait for search completion
      await tester.pumpAndSettle();

      // Should always show both sections
      expect(find.byType(InternalBooksSection), findsOneWidget);
      expect(find.byType(GoogleBooksSection), findsOneWidget);
      
      // Should show appropriate counts
      expect(find.text('Our Database (1)'), findsOneWidget);
      expect(find.text('Google Books (0)'), findsOneWidget);
      
      // Should show no results message only for Google Books
      expect(find.byType(NoResultsMessage), findsOneWidget);
      expect(find.text('No books found in Google Books'), findsOneWidget);
      expect(find.text('No books found in our database'), findsNothing);
    });

    testWidgets('should show both sections when Google has results but internal is empty', (WidgetTester tester) async {
      // Mock Google results but empty internal response
      final emptyInternalResponse = InternalBookSearchResponse(
        books: [],
        total: 0,
        count: 0,
        offset: 0,
      );
      
      final googleResponse = BookSearchResponse(
        items: [
          BookSearchItem(
            id: 'google_1',
            title: 'Test Google Book',
            authors: ['Google Author'],
            description: 'Test Google description',
            imageUrl: 'https://books.google.com/cover.jpg',
            pageCount: 200,
            publisher: 'Test Publisher',
            publishedDate: '2024',
            language: 'en',
            categories: ['Fiction'],
            industryIdentifiers: [],
          ),
        ],
        totalItems: 1,
      );
      
      when(mockBookApiService.searchInternalBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => emptyInternalResponse);
      
      when(mockBookApiService.searchGoogleBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        maxResults: anyNamed('maxResults'),
        startIndex: anyNamed('startIndex'),
      )).thenAnswer((_) async => googleResponse);

      await tester.pumpWidget(createBookSearchScreen());
      
      // Enter search terms
      await tester.enterText(find.byType(TextField).first, 'google only book');
      
      // Tap search button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search Books'));
      await tester.pump();
      
      // Wait for search completion
      await tester.pumpAndSettle();

      // Should always show both sections
      expect(find.byType(InternalBooksSection), findsOneWidget);
      expect(find.byType(GoogleBooksSection), findsOneWidget);
      
      // Should show appropriate counts
      expect(find.text('Our Database (0)'), findsOneWidget);
      expect(find.text('Google Books (1)'), findsOneWidget);
      
      // Should show no results message only for internal database
      expect(find.byType(NoResultsMessage), findsOneWidget);
      expect(find.text('No books found in our database'), findsOneWidget);
      expect(find.text('No books found in Google Books'), findsNothing);
    });

    testWidgets('should not show sections before search is performed', (WidgetTester tester) async {
      await tester.pumpWidget(createBookSearchScreen());
      
      // Before any search is performed, sections should not be visible
      expect(find.byType(InternalBooksSection), findsNothing);
      expect(find.byType(GoogleBooksSection), findsNothing);
      
      // Should show initial state message
      expect(find.text('Start your search'), findsOneWidget);
    });

    testWidgets('should show loading state for both sections during search', (WidgetTester tester) async {
      // Mock delayed responses
      final emptyInternalResponse = InternalBookSearchResponse(
        books: [],
        total: 0,
        count: 0,
        offset: 0,
      );
      
      final emptyGoogleResponse = BookSearchResponse(
        items: [],
        totalItems: 0,
      );
      
      when(mockBookApiService.searchInternalBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return emptyInternalResponse;
      });
      
      when(mockBookApiService.searchGoogleBooks(
        title: anyNamed('title'),
        author: anyNamed('author'),
        maxResults: anyNamed('maxResults'),
        startIndex: anyNamed('startIndex'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return emptyGoogleResponse;
      });

      await tester.pumpWidget(createBookSearchScreen());
      
      // Enter search terms
      await tester.enterText(find.byType(TextField).first, 'test book');
      
      // Tap search button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search Books'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Searching both databases...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      
      // Sections should not be visible during loading
      expect(find.byType(InternalBooksSection), findsNothing);
      expect(find.byType(GoogleBooksSection), findsNothing);
      
      // Wait for search to complete
      await tester.pumpAndSettle();
      
      // Now sections should be visible
      expect(find.byType(InternalBooksSection), findsOneWidget);
      expect(find.byType(GoogleBooksSection), findsOneWidget);
    });
  });
}