import 'insight_type.dart';

class SavedInsightBook {
  final String id;
  final String title;
  final List<String> authors;
  final String? imageUrl;

  SavedInsightBook({
    required this.id,
    required this.title,
    required this.authors,
    this.imageUrl,
  });

  factory SavedInsightBook.fromJson(Map<String, dynamic> json) {
    return SavedInsightBook(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authors: (json['authors'] as List<dynamic>?)
          ?.map((author) => author.toString())
          .toList() ?? [],
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'imageUrl': imageUrl,
    };
  }
}

class SavedInsightWithBook {
  final String id;
  final String content;
  final InsightType type;
  final String language;
  final DateTime createdAt;
  final bool isSaved;
  final SavedInsightBook book;

  SavedInsightWithBook({
    required this.id,
    required this.content,
    required this.type,
    required this.language,
    required this.createdAt,
    required this.isSaved,
    required this.book,
  });

  factory SavedInsightWithBook.fromJson(Map<String, dynamic> json) {
    return SavedInsightWithBook(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: InsightType.fromString(json['type']?.toString()),
      language: json['language']?.toString() ?? 'en',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isSaved: json['isSaved'] as bool? ?? true, // Always true for saved insights
      book: SavedInsightBook.fromJson(json['book'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.value,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
      'book': book.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedInsightWithBook &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SavedInsightsListResponse {
  final List<SavedInsightWithBook> insights;
  final int total;
  final int limit;
  final int offset;

  SavedInsightsListResponse({
    required this.insights,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory SavedInsightsListResponse.fromJson(Map<String, dynamic> json) {
    return SavedInsightsListResponse(
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((insight) => SavedInsightWithBook.fromJson(insight as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      offset: json['offset'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insights': insights.map((insight) => insight.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}