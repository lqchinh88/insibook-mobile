import 'book_models.dart';

class SavedInsightResponse {
  final bool success;
  final String action;
  final bool isSaved;

  SavedInsightResponse({
    required this.success,
    required this.action,
    required this.isSaved,
  });

  factory SavedInsightResponse.fromJson(Map<String, dynamic> json) {
    return SavedInsightResponse(
      success: json['success'] as bool? ?? false,
      action: json['action']?.toString() ?? '',
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'action': action,
      'isSaved': isSaved,
    };
  }
}

class BookmarkResponse {
  final bool success;
  final String action;
  final bool isBookmarked;

  BookmarkResponse({
    required this.success,
    required this.action,
    required this.isBookmarked,
  });

  factory BookmarkResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkResponse(
      success: json['success'] as bool? ?? false,
      action: json['action']?.toString() ?? '',
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'action': action,
      'isBookmarked': isBookmarked,
    };
  }
}

class BookmarkedBooksResponse {
  final List<InternalBookItem> books;
  final int total;
  final int limit;
  final int offset;

  BookmarkedBooksResponse({
    required this.books,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory BookmarkedBooksResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkedBooksResponse(
      books: (json['books'] as List<dynamic>? ?? [])
          .map((book) => InternalBookItem.fromJson(book as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      offset: json['offset'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'books': books.map((book) => {
        'id': book.id,
        'title': book.title,
        'authors': book.authors,
        // Add other fields as needed - simplified for now
      }).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}