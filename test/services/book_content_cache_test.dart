import 'package:flutter_test/flutter_test.dart';
import 'package:insibook_mobile/models/book_models.dart';
import 'package:insibook_mobile/models/insight.dart';
import 'package:insibook_mobile/models/insight_type.dart';
import 'package:insibook_mobile/services/book_content_cache.dart';

void main() {
  group('BookContentCache', () {
    setUp(() {
      // Clear cache before each test
      BookContentCache.clear();
    });

    // Helper to create test book content
    BookWithContent createTestBook(String id, String language, {bool withInsights = true}) {
      return BookWithContent(
        id: id,
        googleBookId: 'google-$id',
        title: 'Test Book $id',
        authors: ['Test Author'],
        categories: [],
        language: language,
        summaryCount: 1,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
        summary: Summary(chapters: []),
        insights: withInsights ? [
          Insight(
            id: 'insight-$id',
            content: 'Test insight for book $id',
            type: InsightType.keyIdea,
            language: language,
            createdAt: DateTime(2024, 1, 1),
            order: 1,
          ),
        ] : null,
      );
    }

    test('should generate correct cache key', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book1', 'vi', createTestBook('book1', 'vi'));
      
      expect(BookContentCache.has('book1', 'en'), isTrue);
      expect(BookContentCache.has('book1', 'vi'), isTrue);
      expect(BookContentCache.has('book1', 'fr'), isFalse);
    });

    test('should store and retrieve cached content', () {
      final testBook = createTestBook('test-id', 'en');
      
      BookContentCache.set('test-id', 'en', testBook);
      final retrieved = BookContentCache.get('test-id', 'en');
      
      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals('test-id'));
      expect(retrieved?.title, equals('Test Book test-id'));
      expect(retrieved?.hasInsights, isTrue);
    });

    test('should handle multi-language caching for same book', () {
      final englishBook = createTestBook('book1', 'en');
      final vietnameseBook = createTestBook('book1', 'vi');
      
      BookContentCache.set('book1', 'en', englishBook);
      BookContentCache.set('book1', 'vi', vietnameseBook);
      
      final retrievedEn = BookContentCache.get('book1', 'en');
      final retrievedVi = BookContentCache.get('book1', 'vi');
      
      expect(retrievedEn?.language, equals('en'));
      expect(retrievedVi?.language, equals('vi'));
      expect(BookContentCache.getCachedLanguagesForBook('book1').length, equals(2));
    });

    test('hasInsights should work correctly', () {
      final bookWithInsights = createTestBook('book-insights', 'en', withInsights: true);
      final bookWithoutInsights = createTestBook('book-no-insights', 'en', withInsights: false);
      
      BookContentCache.set('book-insights', 'en', bookWithInsights);
      BookContentCache.set('book-no-insights', 'en', bookWithoutInsights);
      
      expect(BookContentCache.hasInsights('book-insights', 'en'), isTrue);
      expect(BookContentCache.hasInsights('book-no-insights', 'en'), isFalse);
      expect(BookContentCache.hasInsights('non-existent', 'en'), isFalse);
    });

    test('should implement LRU eviction when cache is full', () {
      // Fill cache to max capacity
      for (int i = 1; i <= 50; i++) {
        BookContentCache.set('book$i', 'en', createTestBook('book$i', 'en'));
      }
      
      expect(BookContentCache.getStats()['size'], equals(50));
      
      // Access book1 to make it recently used
      BookContentCache.get('book1', 'en');
      
      // Add one more item, should evict least recently used (not book1)
      BookContentCache.set('book51', 'en', createTestBook('book51', 'en'));
      
      expect(BookContentCache.getStats()['size'], equals(50));
      expect(BookContentCache.has('book1', 'en'), isTrue); // Should still be there
      expect(BookContentCache.has('book51', 'en'), isTrue); // New item should be added
    });

    test('should track access times correctly', () {
      final book1 = createTestBook('book1', 'en');
      final book2 = createTestBook('book2', 'en');
      
      BookContentCache.set('book1', 'en', book1);
      BookContentCache.set('book2', 'en', book2);
      
      // Access book1 to update its access time
      BookContentCache.get('book1', 'en');
      
      expect(BookContentCache.has('book1', 'en'), isTrue);
      expect(BookContentCache.has('book2', 'en'), isTrue);
    });

    test('should provide cache statistics', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book2', 'vi', createTestBook('book2', 'vi'));
      
      final stats = BookContentCache.getStats();
      
      expect(stats['size'], equals(2));
      expect(stats['maxSize'], equals(50));
      expect(stats['keys'], isList);
      expect((stats['keys'] as List).length, equals(2));
      expect(stats['usage'], equals('4.0')); // 2/50 * 100
    });

    test('should get cached book IDs correctly', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book1', 'vi', createTestBook('book1', 'vi'));
      BookContentCache.set('book2', 'en', createTestBook('book2', 'en'));
      
      final cachedIds = BookContentCache.getCachedBookIds();
      
      expect(cachedIds.length, equals(2));
      expect(cachedIds, contains('book1'));
      expect(cachedIds, contains('book2'));
    });

    test('should get cached languages for specific book', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book1', 'vi', createTestBook('book1', 'vi'));
      BookContentCache.set('book1', 'fr', createTestBook('book1', 'fr'));
      
      final languages = BookContentCache.getCachedLanguagesForBook('book1');
      
      expect(languages.length, equals(3));
      expect(languages, contains('en'));
      expect(languages, contains('vi'));
      expect(languages, contains('fr'));
    });

    test('should remove specific book and language', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book1', 'vi', createTestBook('book1', 'vi'));
      
      BookContentCache.remove('book1', 'en');
      
      expect(BookContentCache.has('book1', 'en'), isFalse);
      expect(BookContentCache.has('book1', 'vi'), isTrue);
    });

    test('should remove all languages for a book', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book1', 'vi', createTestBook('book1', 'vi'));
      BookContentCache.set('book2', 'en', createTestBook('book2', 'en'));
      
      BookContentCache.removeBook('book1');
      
      expect(BookContentCache.has('book1', 'en'), isFalse);
      expect(BookContentCache.has('book1', 'vi'), isFalse);
      expect(BookContentCache.has('book2', 'en'), isTrue);
    });

    test('should clear all cache', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book2', 'vi', createTestBook('book2', 'vi'));
      
      expect(BookContentCache.getStats()['size'], equals(2));
      
      BookContentCache.clear();
      
      expect(BookContentCache.getStats()['size'], equals(0));
      expect(BookContentCache.has('book1', 'en'), isFalse);
    });

    test('should handle force eviction', () {
      BookContentCache.set('book1', 'en', createTestBook('book1', 'en'));
      BookContentCache.set('book2', 'en', createTestBook('book2', 'en'));
      BookContentCache.set('book3', 'en', createTestBook('book3', 'en'));
      
      expect(BookContentCache.getStats()['size'], equals(3));
      
      BookContentCache.evictLRU(count: 2);
      
      expect(BookContentCache.getStats()['size'], equals(1));
    });

    test('should handle edge cases gracefully', () {
      // Test with null/empty values
      expect(BookContentCache.get('', ''), isNull);
      expect(BookContentCache.has('', ''), isFalse);
      expect(BookContentCache.hasInsights('non-existent', 'en'), isFalse);
      
      // Test eviction on empty cache
      BookContentCache.evictLRU();
      expect(BookContentCache.getStats()['size'], equals(0));
    });

    test('should update access time on get operations', () {
      final book = createTestBook('test', 'en');
      BookContentCache.set('test', 'en', book);
      
      // Get the book multiple times
      BookContentCache.get('test', 'en');
      BookContentCache.get('test', 'en');
      
      // Should still be accessible
      expect(BookContentCache.has('test', 'en'), isTrue);
    });
  });
}