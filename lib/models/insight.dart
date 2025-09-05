import 'insight_type.dart';

class Insight {
  final String id;
  final String content;
  final InsightType type;
  final String language;
  final DateTime createdAt;
  final int order;

  const Insight({
    required this.id,
    required this.content,
    required this.type,
    required this.language,
    required this.createdAt,
    required this.order,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: InsightType.fromString(json['type']?.toString()),
      language: json['language']?.toString() ?? 'en',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      order: json['order'] is int ? json['order'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.value,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Insight &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          type == other.type &&
          language == other.language &&
          order == other.order;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      type.hashCode ^
      language.hashCode ^
      order.hashCode;
}