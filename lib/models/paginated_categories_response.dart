import 'book_models.dart';

class PaginatedCategoriesResponse {
  final List<BookCategory> categories;
  final bool hasMore;
  final int totalCount;
  final int offset;
  final int limit;

  PaginatedCategoriesResponse({
    required this.categories,
    required this.hasMore,
    required this.totalCount,
    required this.offset,
    required this.limit,
  });

  factory PaginatedCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final categories = data
        .map((category) => BookCategory.fromJson(category))
        .toList();

    final totalCount = json['total'] ?? 0;
    final offset = json['offset'] ?? 0;
    final count = json['count'] ?? categories.length;

    // Calculate hasMore based on whether there are more items available
    final hasMore = (offset + count) < totalCount;

    return PaginatedCategoriesResponse(
      categories: categories,
      hasMore: hasMore,
      totalCount: totalCount,
      offset: offset,
      limit: count,
    );
  }
}