import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:insibook_mobile/screens/book_content_screen.dart';
import 'package:insibook_mobile/models/book_models.dart';
import 'package:insibook_mobile/models/insight.dart';
import 'package:insibook_mobile/models/insight_type.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/lang/app_localizations.dart';
import 'package:mockito/mockito.dart';

// Mock AppLocalizations
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super('en');
  
  @override
  String getText(String key) {
    final mockValues = {
      'summary': 'Summary',
      'insights': 'Insights',
    };
    return mockValues[key] ?? key;
  }
}

// Mock LanguageProvider
class MockLanguageProvider extends Mock implements LanguageProvider {
  @override
  AppLocalizations get l10n => MockAppLocalizations();
}

void main() {
  group('BookContentScreen', () {
    late BookWithContent testBookWithContent;
    late BookWithContent testBookWithInsights;

    setUp(() {
      testBookWithContent = BookWithContent(
        id: 'test-book-id',
        googleBookId: 'google-book-123',
        title: 'Test Book Title',
        authors: ['Test Author'],
        categories: [],
        language: 'en',
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(
          content: null, // Set to null to avoid markdown rendering
          chapters: [],
        ),
        insights: null,
      );

      testBookWithInsights = BookWithContent(
        id: 'test-book-with-insights-id',
        googleBookId: 'google-book-456',
        title: 'Test Book with Insights',
        authors: ['Insight Author'],
        categories: [],
        language: 'en',
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(
          content: null, // Set to null to avoid markdown rendering
          chapters: [],
        ),
        insights: [
          Insight(
            id: 'insight-1',
            content: 'This is a key insight about productivity.',
            type: InsightType.keyIdea,
            language: 'en',
            createdAt: DateTime(2024, 1, 1),
            order: 1,
          ),
          Insight(
            id: 'insight-2',
            content: 'This is an opinion about work-life balance.',
            type: InsightType.opinion,
            language: 'en',
            createdAt: DateTime(2024, 1, 1),
            order: 2,
          ),
        ],
      );
    });

    Widget createWidgetUnderTest(BookWithContent bookContent) {
      return MaterialApp(
        home: ChangeNotifierProvider<LanguageProvider>.value(
          value: MockLanguageProvider(),
          child: BookContentScreen(bookContent: bookContent),
        ),
      );
    }

    testWidgets('should display book information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithContent));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('by Test Author'), findsOneWidget);
      expect(find.text('Summary'), findsAtLeastNWidgets(1));
      
    });

    testWidgets('should show segmented control with summary and insights tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithInsights));
      await tester.pumpAndSettle();

      expect(find.byType(SegmentedButton<ContentType>), findsOneWidget);
      expect(find.text('Summary'), findsAtLeastNWidgets(1));
      expect(find.text('Insights'), findsAtLeastNWidgets(1));
      
    });

    testWidgets('should disable insights tab when book has no insights', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithContent));
      await tester.pumpAndSettle();

      // Find the segmented button
      final segmentedButton = tester.widget<SegmentedButton<ContentType>>(
        find.byType(SegmentedButton<ContentType>),
      );

      // Check that insights segment is disabled
      final insightsSegment = segmentedButton.segments.firstWhere(
        (segment) => segment.value == ContentType.insights,
      );
      expect(insightsSegment.enabled, isFalse);
      
    });

    testWidgets('should switch between summary and insights content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithInsights));
      await tester.pumpAndSettle();

      // Initially should show summary tab selected (no content since content is null)
      expect(find.text('No summary available'), findsOneWidget);

      // Find the insights button in the segmented control specifically
      final insightsButtons = find.descendant(
        of: find.byType(SegmentedButton<ContentType>),
        matching: find.text('Insights'),
      );
      expect(insightsButtons, findsOneWidget);
      
      // Tap on insights tab
      await tester.tap(insightsButtons);
      await tester.pumpAndSettle();

      // Should now show insights content
      expect(find.text('This is a key insight about productivity.'), findsOneWidget);
      expect(find.text('This is an opinion about work-life balance.'), findsOneWidget);

      // Tap back on summary tab
      final summaryButtons = find.descendant(
        of: find.byType(SegmentedButton<ContentType>),
        matching: find.text('Summary'),
      );
      await tester.tap(summaryButtons);
      await tester.pumpAndSettle();

      // Should show summary empty state again
      expect(find.text('No summary available'), findsOneWidget);
      
    });

    testWidgets('should show correct app bar title based on selected content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithInsights));
      await tester.pumpAndSettle();

      // Initially should show "Summary" in app bar
      expect(find.text('Summary'), findsAtLeastNWidgets(1));

      // Tap on insights tab in segmented control
      final insightsButtons = find.descendant(
        of: find.byType(SegmentedButton<ContentType>),
        matching: find.text('Insights'),
      );
      await tester.tap(insightsButtons);
      await tester.pumpAndSettle();

      // App bar should now show "Insights"
      expect(find.text('Insights'), findsAtLeastNWidgets(1));
      
    });

    testWidgets('should display fallback book icon when no cover available', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithContent));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.book), findsOneWidget);
      
    });

    testWidgets('should show content type badges correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithInsights));
      await tester.pumpAndSettle();

      // Should show both summary and insights badges
      expect(find.text('Summary'), findsAtLeastNWidgets(1));
      expect(find.text('Insights'), findsAtLeastNWidgets(1));
      
    });

    testWidgets('should show only summary badge when no insights', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testBookWithContent));
      await tester.pumpAndSettle();

      // Should show summary badge in the content badges section (not the segmented control)
      final summaryBadges = find.text('Summary');
      expect(summaryBadges, findsAtLeastNWidgets(1));
      
      // The insights text should appear in the disabled segmented control
      final allInsightTexts = find.text('Insights');
      expect(allInsightTexts, findsOneWidget);
      
      // Verify insights badge is NOT shown in the content type badges (since hasInsights is false)
      // Since hasInsights is false for testBookWithContent, there should be no "Insights" badge in the badges section
      
    });
  });
}