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
  final String? googleBookImageUrl;
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
    this.googleBookImageUrl,
    this.previewLink,
    this.infoLink,
    this.canonicalLink,
    required this.summaryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the display image URL, prioritizing Google Books image URL over regular imageUrl
  String? get displayImageUrl {
    if (googleBookImageUrl != null && googleBookImageUrl!.isNotEmpty) {
      return _proxyGoogleBooksImage(googleBookImageUrl!);
    }
    return imageUrl;
  }

  /// Proxy Google Books images to bypass CORS restrictions
  String _proxyGoogleBooksImage(String url) {
    // Use a proxy service to bypass CORS restrictions for Google Books images
    if (url.contains('books.google.com')) {
      // Use images.weserv.nl as a proxy to bypass CORS
      String encodedUrl = Uri.encodeComponent(url);
      return 'https://images.weserv.nl/?url=$encodedUrl&w=160&h=240&fit=cover';
    }
    return url;
  }

  factory InternalBookItem.fromJson(Map<String, dynamic> json) {
    return InternalBookItem(
      id: json['id']?.toString() ?? '',
      googleBookId: json['googleBookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      authors: List<String>.from(json['authors'] ?? []),
      publisher: json['publisher']?.toString(),
      publishedDate: json['publishedDate']?.toString(),
      description: json['description']?.toString(),
      categories: List<String>.from(json['categories'] ?? []),
      language: json['language']?.toString() ?? 'en',
      pageCount: json['pageCount'] is int ? json['pageCount'] : null,
      imageUrl: json['imageUrl']?.toString(),
      googleBookImageUrl: json['googleBookCoverImageUrl']?.toString(),
      previewLink: json['previewLink']?.toString(),
      infoLink: json['infoLink']?.toString(),
      canonicalLink: json['canonicalLink']?.toString(),
      summaryCount: json['summaryCount'] is int ? json['summaryCount'] : 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
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

class SummaryChapter {
  final String id;
  final String name;
  final String content;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  SummaryChapter({
    required this.id,
    required this.name,
    required this.content,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SummaryChapter.fromJson(Map<String, dynamic> json) {
    return SummaryChapter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      order: json['order'] is int ? json['order'] : 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Summary {
  final String? introduction;
  final String? finalThoughts;
  final List<SummaryChapter> chapters;

  Summary({this.introduction, this.finalThoughts, required this.chapters});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      introduction: json['introduction']?.toString(),
      finalThoughts: json['finalThoughts']?.toString(),
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((chapter) => SummaryChapter.fromJson(chapter))
          .toList(),
    );
  }
}

class BookWithSummary extends InternalBookItem {
  final Summary summary;

  BookWithSummary({
    required super.id,
    required super.googleBookId,
    required super.title,
    super.subtitle,
    required super.authors,
    super.publisher,
    super.publishedDate,
    super.description,
    required super.categories,
    required super.language,
    super.pageCount,
    super.imageUrl,
    super.googleBookImageUrl,
    super.previewLink,
    super.infoLink,
    super.canonicalLink,
    required super.summaryCount,
    required super.createdAt,
    required super.updatedAt,
    required this.summary,
  });

  factory BookWithSummary.fromJson(Map<String, dynamic> json) {
    return BookWithSummary(
      id: json['id']?.toString() ?? '',
      googleBookId: json['googleBookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      authors: List<String>.from(json['authors'] ?? []),
      publisher: json['publisher']?.toString(),
      publishedDate: json['publishedDate']?.toString(),
      description: json['description']?.toString(),
      categories: List<String>.from(json['categories'] ?? []),
      language: json['language']?.toString() ?? 'en',
      pageCount: json['pageCount'] is int ? json['pageCount'] : null,
      imageUrl: json['imageUrl']?.toString(),
      googleBookImageUrl: json['googleBookCoverImageUrl']?.toString(),
      previewLink: json['previewLink']?.toString(),
      infoLink: json['infoLink']?.toString(),
      canonicalLink: json['canonicalLink']?.toString(),
      summaryCount: json['summaryCount'] is int ? json['summaryCount'] : 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      summary: Summary.fromJson(json['summary'] ?? {}),
    );
  }
}
