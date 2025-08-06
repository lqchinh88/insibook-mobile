class InternalBookItem {
  final String id;
  final String googleBookId;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final List<String> categories;
  final String language;
  final int? pageCount;
  final String? imageUrl;
  final String? previewLink;
  final String? infoLink;
  final String? canonicalLink;
  final int summaryCount;
  final String createdAt;
  final String updatedAt;

  InternalBookItem({
    required this.id,
    required this.googleBookId,
    required this.title,
    this.subtitle,
    required this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    required this.categories,
    required this.language,
    this.pageCount,
    this.imageUrl,
    this.previewLink,
    this.infoLink,
    this.canonicalLink,
    required this.summaryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternalBookItem.fromJson(Map<String, dynamic> json) {
    return InternalBookItem(
      id: json['id'],
      googleBookId: json['googleBookId'],
      title: json['title'],
      subtitle: json['subtitle'],
      authors: List<String>.from(json['authors'] ?? []),
      publisher: json['publisher'],
      publishedDate: json['publishedDate'],
      description: json['description'],
      categories: List<String>.from(json['categories'] ?? []),
      language: json['language'],
      pageCount: json['pageCount'],
      imageUrl: json['imageUrl'],
      previewLink: json['previewLink'],
      infoLink: json['infoLink'],
      canonicalLink: json['canonicalLink'],
      summaryCount: json['summaryCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class InternalBookSearchResponse {
  final int total;
  final int count;
  final int offset;
  final List<InternalBookItem> books;

  InternalBookSearchResponse({
    required this.total,
    required this.count,
    required this.offset,
    required this.books,
  });

  factory InternalBookSearchResponse.fromJson(Map<String, dynamic> json) {
    return InternalBookSearchResponse(
      total: json['total'],
      count: json['count'],
      offset: json['offset'],
      books: (json['books'] as List)
          .map((book) => InternalBookItem.fromJson(book))
          .toList(),
    );
  }
}

class BookSearchItem {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final String? imageUrl;
  final String? language;
  final String? publishedDate;
  final int pageCount;
  final List<String> categories;

  BookSearchItem({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.imageUrl,
    this.language,
    this.publishedDate,
    required this.pageCount,
    required this.categories,
  });

  factory BookSearchItem.fromJson(Map<String, dynamic> json) {
    try {
      return BookSearchItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        authors: List<String>.from(json['authors'] ?? []),
        description: json['description'],
        imageUrl: json['imageUrl'],
        language: json['language'],
        publishedDate: json['publishedDate'],
        pageCount: json['pageCount'] ?? 0,
        categories: List<String>.from(json['categories'] ?? []),
      );
    } catch (e) {
      print('Error parsing BookSearchItem: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

class BookSearchResponse {
  final int totalItems;
  final List<BookSearchItem> items;

  BookSearchResponse({required this.totalItems, required this.items});

  factory BookSearchResponse.fromJson(Map<String, dynamic> json) {
    return BookSearchResponse(
      totalItems: json['totalItems'],
      items: (json['items'] as List)
          .map((item) => BookSearchItem.fromJson(item))
          .toList(),
    );
  }
}
