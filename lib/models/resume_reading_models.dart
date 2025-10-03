import 'book_models.dart';

class ResumeReadingItem {
  final InternalBookItem book;
  final ReadingProgress readingProgress;

  ResumeReadingItem({
    required this.book,
    required this.readingProgress,
  });

  factory ResumeReadingItem.fromJson(Map<String, dynamic> json) {
    return ResumeReadingItem(
      book: InternalBookItem.fromJson(json['book'] ?? {}),
      readingProgress: ReadingProgress.fromJson(json['readingProgress'] ?? {}),
    );
  }
}

class ResumeReadingResponse {
  final List<ResumeReadingItem> items;

  ResumeReadingResponse({required this.items});

  factory ResumeReadingResponse.fromJson(Map<String, dynamic> json) {
    // Fix: API returns data as direct array, not object with 'books' key
    final dataJson = json['data'] as List<dynamic>? ?? [];
    final items = dataJson
        .map((itemJson) => ResumeReadingItem.fromJson(itemJson))
        .toList();

    return ResumeReadingResponse(items: items);
  }
}