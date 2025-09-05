import 'package:flutter_test/flutter_test.dart';
import 'package:insibook_mobile/models/book_models.dart';
import 'package:insibook_mobile/models/insight.dart';
import 'package:insibook_mobile/models/insight_type.dart';

void main() {
  group('BookWithContent', () {
    final testBookWithContent = BookWithContent(
      id: 'test-book-id',
      googleBookId: 'google-book-123',
      title: 'Test Book Title',
      subtitle: 'Test Subtitle',
      authors: ['Author One', 'Author Two'],
      publisher: 'Test Publisher',
      publishedDate: '2024-01-01',
      description: 'This is a test book description.',
      categories: [],
      language: 'en',
      pageCount: 250,
      imageUrl: 'https://example.com/image.jpg',
      summaryCount: 1,
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
      summary: Summary(
        introduction: 'Test introduction',
        finalThoughts: 'Test final thoughts',
        content: 'Test content',
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

    test('should create instance with all fields including insights', () {
      expect(testBookWithContent.id, equals('test-book-id'));
      expect(testBookWithContent.title, equals('Test Book Title'));
      expect(testBookWithContent.insights, isNotNull);
      expect(testBookWithContent.insights?.length, equals(2));
      expect(testBookWithContent.hasInsights, isTrue);
    });

    test('hasInsights should return true when insights are present', () {
      expect(testBookWithContent.hasInsights, isTrue);
    });

    test('hasInsights should return false when insights are null', () {
      final bookWithoutInsights = BookWithContent(
        id: 'test-book-id',
        googleBookId: 'google-book-123',
        title: 'Test Book Title',
        authors: ['Author One'],
        categories: [],
        language: 'en',
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(chapters: []),
        insights: null, // No insights
      );

      expect(bookWithoutInsights.hasInsights, isFalse);
    });

    test('hasInsights should return false when insights are empty', () {
      final bookWithEmptyInsights = BookWithContent(
        id: 'test-book-id',
        googleBookId: 'google-book-123',
        title: 'Test Book Title',
        authors: ['Author One'],
        categories: [],
        language: 'en',
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(chapters: []),
        insights: [], // Empty insights
      );

      expect(bookWithEmptyInsights.hasInsights, isFalse);
    });

    test('fromJson should parse unified API response with both summary and insights', () {
      final json = {
        'id': 'book-123',
        'googleBookId': 'google-456',
        'title': 'JSON Test Book',
        'authors': ['JSON Author'],
        'categories': [],
        'language': 'en',
        'summaryCount': 1,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'summary': {
          'introduction': 'Test intro',
          'chapters': [],
        },
        'insights': [
          {
            'id': 'insight-json-1',
            'content': 'JSON insight content',
            'type': 'key_idea',
            'language': 'en',
            'createdAt': '2024-01-01T00:00:00Z',
            'order': 1,
          }
        ],
      };

      final book = BookWithContent.fromJson(json);

      expect(book.id, equals('book-123'));
      expect(book.title, equals('JSON Test Book'));
      expect(book.hasInsights, isTrue);
      expect(book.insights?.length, equals(1));
      expect(book.insights?.first.content, equals('JSON insight content'));
      expect(book.insights?.first.type, equals(InsightType.keyIdea));
    });

    test('fromJson should handle API response without insights', () {
      final json = {
        'id': 'book-no-insights',
        'googleBookId': 'google-789',
        'title': 'No Insights Book',
        'authors': ['Author'],
        'categories': [],
        'language': 'en',
        'summaryCount': 1,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'summary': {
          'introduction': 'Test intro',
          'chapters': [],
        },
        // No insights field
      };

      final book = BookWithContent.fromJson(json);

      expect(book.id, equals('book-no-insights'));
      expect(book.hasInsights, isFalse);
      expect(book.insights, isNull);
    });

    test('toJson should serialize correctly with insights', () {
      final json = testBookWithContent.toJson();

      expect(json['id'], equals('test-book-id'));
      expect(json['title'], equals('Test Book Title'));
      expect(json['insights'], isNotNull);
      expect(json['insights'], isList);
      expect((json['insights'] as List).length, equals(2));
      
      final firstInsight = (json['insights'] as List)[0];
      expect(firstInsight['content'], equals('This is a key insight about productivity.'));
      expect(firstInsight['type'], equals('key_idea'));
    });

    test('toJson should handle null insights', () {
      final bookWithoutInsights = BookWithContent(
        id: 'test-book-id',
        googleBookId: 'google-book-123',
        title: 'Test Book Title',
        authors: ['Author One'],
        categories: [],
        language: 'en',
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(chapters: []),
        insights: null,
      );

      final json = bookWithoutInsights.toJson();

      expect(json['insights'], isNull);
    });
  });
}