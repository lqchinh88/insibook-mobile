import 'package:flutter_test/flutter_test.dart';
import 'package:insibook_mobile/models/insight.dart';
import 'package:insibook_mobile/models/insight_type.dart';

void main() {
  group('Insight', () {
    final testInsight = Insight(
      id: 'test-id',
      content: 'This is a test insight about productivity and time management.',
      type: InsightType.keyIdea,
      language: 'en',
      createdAt: DateTime(2024, 1, 1),
      order: 1,
    );

    test('should create instance with all required fields', () {
      expect(testInsight.id, equals('test-id'));
      expect(testInsight.content, equals('This is a test insight about productivity and time management.'));
      expect(testInsight.type, equals(InsightType.keyIdea));
      expect(testInsight.language, equals('en'));
      expect(testInsight.createdAt, equals(DateTime(2024, 1, 1)));
      expect(testInsight.order, equals(1));
    });

    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'id': 'test-id-2',
        'content': 'Building habits requires consistency and patience.',
        'type': 'habit',
        'language': 'en',
        'createdAt': '2024-01-02T00:00:00.000Z',
        'order': 2,
      };

      final insight = Insight.fromJson(json);

      expect(insight.id, equals('test-id-2'));
      expect(insight.content, equals('Building habits requires consistency and patience.'));
      expect(insight.type, equals(InsightType.habit));
      expect(insight.language, equals('en'));
      expect(insight.createdAt, equals(DateTime.parse('2024-01-02T00:00:00.000Z')));
      expect(insight.order, equals(2));
    });

    test('fromJson should handle missing fields gracefully', () {
      final json = {
        'content': 'Minimal insight data',
        'type': 'opinion',
      };

      final insight = Insight.fromJson(json);

      expect(insight.id, equals(''));
      expect(insight.content, equals('Minimal insight data'));
      expect(insight.type, equals(InsightType.opinion));
      expect(insight.language, equals('en')); // Default fallback
      expect(insight.order, equals(0)); // Default fallback
      // createdAt should be close to now
      expect(insight.createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 1))), isTrue);
    });

    test('fromJson should handle malformed JSON', () {
      final json = {
        'id': 123, // Wrong type, should convert to string
        'content': null, // Null content
        'type': 'invalid_type', // Invalid type, should fallback
        'language': null, // Null language
        'createdAt': 'invalid_date', // Invalid date
        'order': 'not_a_number', // Wrong type
      };

      final insight = Insight.fromJson(json);

      expect(insight.id, equals('123'));
      expect(insight.content, equals(''));
      expect(insight.type, equals(InsightType.keyIdea)); // Fallback
      expect(insight.language, equals('en')); // Fallback
      expect(insight.order, equals(0)); // Fallback
    });

    test('toJson should serialize correctly', () {
      final json = testInsight.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['content'], equals('This is a test insight about productivity and time management.'));
      expect(json['type'], equals('key_idea'));
      expect(json['language'], equals('en'));
      expect(json['createdAt'], equals('2024-01-01T00:00:00.000'));
      expect(json['order'], equals(1));
    });

    test('equality should work correctly', () {
      final insight1 = Insight(
        id: 'same-id',
        content: 'Same content',
        type: InsightType.keyIdea,
        language: 'en',
        createdAt: DateTime(2024, 1, 1),
        order: 1,
      );

      final insight2 = Insight(
        id: 'same-id',
        content: 'Same content',
        type: InsightType.keyIdea,
        language: 'en',
        createdAt: DateTime(2024, 1, 1),
        order: 1,
      );

      final insight3 = Insight(
        id: 'different-id',
        content: 'Same content',
        type: InsightType.keyIdea,
        language: 'en',
        createdAt: DateTime(2024, 1, 1),
        order: 1,
      );

      expect(insight1, equals(insight2));
      expect(insight1, isNot(equals(insight3)));
      expect(insight1.hashCode, equals(insight2.hashCode));
      expect(insight1.hashCode, isNot(equals(insight3.hashCode)));
    });
  });
}