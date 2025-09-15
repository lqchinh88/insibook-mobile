import 'insight.dart';

class BookCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  BookCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class InternalBookItem {
  final String id;
  final String googleBookId;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final List<BookCategory> categories;
  final String language;
  final int? pageCount;
  final String? imageUrl;
  final String? googleBookCoverImageUrl;
  final String? previewLink;
  final String? infoLink;
  final String? canonicalLink;
  final List<Map<String, String>>? industryIdentifiers;
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
    this.googleBookCoverImageUrl,
    this.previewLink,
    this.infoLink,
    this.canonicalLink,
    this.industryIdentifiers,
    required this.summaryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the display image URL, prioritizing Google Books image URL over regular imageUrl
  String? get displayImageUrl {
    if (googleBookCoverImageUrl != null &&
        googleBookCoverImageUrl!.isNotEmpty) {
      return _proxyGoogleBooksImage(googleBookCoverImageUrl!);
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
      categories:
          (json['categories'] as List?)
              ?.map((category) => BookCategory.fromJson(category))
              .toList() ??
          [],
      language: json['language']?.toString() ?? 'en',
      pageCount: json['pageCount'] is int ? json['pageCount'] : null,
      imageUrl: json['imageUrl']?.toString(),
      googleBookCoverImageUrl: json['googleBookCoverImageUrl']?.toString(),
      previewLink: json['previewLink']?.toString(),
      infoLink: json['infoLink']?.toString(),
      canonicalLink: json['canonicalLink']?.toString(),
      industryIdentifiers: json['industryIdentifiers'] != null
          ? List<Map<String, String>>.from(
              (json['industryIdentifiers'] as List).map(
                (item) => Map<String, String>.from(item),
              ),
            )
          : null,
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
  final String? publisher;
  final List<Map<String, String>>? industryIdentifiers;

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
    this.publisher,
    this.industryIdentifiers,
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
      publisher: json['publisher'],
      industryIdentifiers: json['industryIdentifiers'] != null
          ? List<Map<String, String>>.from(
              (json['industryIdentifiers'] as List).map(
                (item) => Map<String, String>.from(item),
              ),
            )
          : null,
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
  final String? content;
  final List<SummaryChapter> chapters;

  Summary({
    this.introduction,
    this.finalThoughts,
    this.content,
    required this.chapters,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      introduction: json['introduction']?.toString(),
      finalThoughts: json['finalThoughts']?.toString(),
      content: json['content']?.toString(),
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((chapter) => SummaryChapter.fromJson(chapter))
          .toList(),
    );
  }
}

// BookSyncStatus enum
enum BookSyncStatus {
  pending,
  synced,
  error,
}

// Community rating breakdown
class CommunityRatingBreakdown {
  final int reviewsNum;
  final double reviewsPercentage;

  CommunityRatingBreakdown({
    required this.reviewsNum,
    required this.reviewsPercentage,
  });

  factory CommunityRatingBreakdown.fromJson(Map<String, dynamic> json) {
    return CommunityRatingBreakdown(
      reviewsNum: json['reviews_num'] is int ? json['reviews_num'] : 0,
      reviewsPercentage: (json['reviews_percentage'] is num)
          ? (json['reviews_percentage'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews_num': reviewsNum,
      'reviews_percentage': reviewsPercentage,
    };
  }
}

// Community reviews data
class CommunityReviews {
  final CommunityRatingBreakdown oneStar;
  final CommunityRatingBreakdown twoStar;
  final CommunityRatingBreakdown threeStar;
  final CommunityRatingBreakdown fourStar;
  final CommunityRatingBreakdown fiveStar;

  CommunityReviews({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });

  factory CommunityReviews.fromJson(Map<String, dynamic> json) {
    return CommunityReviews(
      oneStar: CommunityRatingBreakdown.fromJson(json['1_stars'] ?? {}),
      twoStar: CommunityRatingBreakdown.fromJson(json['2_stars'] ?? {}),
      threeStar: CommunityRatingBreakdown.fromJson(json['3_stars'] ?? {}),
      fourStar: CommunityRatingBreakdown.fromJson(json['4_stars'] ?? {}),
      fiveStar: CommunityRatingBreakdown.fromJson(json['5_stars'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '1_stars': oneStar.toJson(),
      '2_stars': twoStar.toJson(),
      '3_stars': threeStar.toJson(),
      '4_stars': fourStar.toJson(),
      '5_stars': fiveStar.toJson(),
    };
  }
}

// About author information
class AboutAuthor {
  final String name;
  final int numBooks;
  final int numFollowers;

  AboutAuthor({
    required this.name,
    required this.numBooks,
    required this.numFollowers,
  });

  factory AboutAuthor.fromJson(Map<String, dynamic> json) {
    return AboutAuthor(
      name: json['name']?.toString() ?? '',
      numBooks: json['num_books'] is int ? json['num_books'] : 0,
      numFollowers: json['num_followers'] is int ? json['num_followers'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'num_books': numBooks,
      'num_followers': numFollowers,
    };
  }
}

// Goodreads book data
class GoodreadsBook {
  final String id;
  final String goodreadsId;
  final String name;
  final List<String> authors;
  final String? isbn;
  final double starRating;
  final int numRatings;
  final int numReviews;
  final String? firstPublished;
  final String? kindlePrice;
  final String url;
  final List<String>? genres;
  final BookSyncStatus bookSyncStatus;
  final AboutAuthor? aboutAuthor;
  final CommunityReviews? communityReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoodreadsBook({
    required this.id,
    required this.goodreadsId,
    required this.name,
    required this.authors,
    this.isbn,
    required this.starRating,
    required this.numRatings,
    required this.numReviews,
    this.firstPublished,
    this.kindlePrice,
    required this.url,
    this.genres,
    required this.bookSyncStatus,
    this.aboutAuthor,
    this.communityReviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoodreadsBook.fromJson(Map<String, dynamic> json) {
    return GoodreadsBook(
      id: json['id']?.toString() ?? '',
      goodreadsId: json['goodreadsId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      isbn: json['isbn']?.toString(),
      starRating: (json['starRating'] is num) ? (json['starRating'] as num).toDouble() : 0.0,
      numRatings: json['numRatings'] is int ? json['numRatings'] : 0,
      numReviews: json['numReviews'] is int ? json['numReviews'] : 0,
      firstPublished: json['firstPublished']?.toString(),
      kindlePrice: json['kindlePrice']?.toString(),
      url: json['url']?.toString() ?? '',
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : null,
      bookSyncStatus: BookSyncStatus.values.firstWhere(
        (status) => status.name == (json['bookSyncStatus']?.toString() ?? 'pending'),
        orElse: () => BookSyncStatus.pending,
      ),
      aboutAuthor: json['aboutAuthor'] != null
          ? AboutAuthor.fromJson(json['aboutAuthor'])
          : null,
      communityReviews: json['communityReviews'] != null
          ? CommunityReviews.fromJson(json['communityReviews'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Helper getter for formatted star rating
  String get formattedStarRating => starRating.toStringAsFixed(1);

  // Helper getter for formatted rating count
  String get formattedRatingCount => '$numRatings ratings';

  // Helper getter for formatted review count
  String get formattedReviewCount => '$numReviews reviews';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goodreadsId': goodreadsId,
      'name': name,
      'authors': authors,
      'isbn': isbn,
      'starRating': starRating,
      'numRatings': numRatings,
      'numReviews': numReviews,
      'firstPublished': firstPublished,
      'kindlePrice': kindlePrice,
      'url': url,
      'genres': genres,
      'bookSyncStatus': bookSyncStatus.name,
      'aboutAuthor': aboutAuthor?.toJson(),
      'communityReviews': communityReviews?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BookWithContent extends InternalBookItem {
  final Summary summary;
  final List<Insight>? insights;
  final GoodreadsBook? goodreadsBook;

  BookWithContent({
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
    super.googleBookCoverImageUrl,
    super.previewLink,
    super.infoLink,
    super.canonicalLink,
    super.industryIdentifiers,
    required super.summaryCount,
    required super.createdAt,
    required super.updatedAt,
    required this.summary,
    this.insights,
    this.goodreadsBook,
  });

  /// Returns true if the book has insights available
  bool get hasInsights => insights != null && insights!.isNotEmpty;

  /// Returns true if the book has Goodreads data available
  bool get hasGoodreadsData => goodreadsBook != null;

  factory BookWithContent.fromJson(Map<String, dynamic> json) {
    return BookWithContent(
      id: json['id']?.toString() ?? '',
      googleBookId: json['googleBookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      authors: List<String>.from(json['authors'] ?? []),
      publisher: json['publisher']?.toString(),
      publishedDate: json['publishedDate']?.toString(),
      description: json['description']?.toString(),
      categories:
          (json['categories'] as List?)
              ?.map((category) => BookCategory.fromJson(category))
              .toList() ??
          [],
      language: json['language']?.toString() ?? 'en',
      pageCount: json['pageCount'] is int ? json['pageCount'] : null,
      imageUrl: json['imageUrl']?.toString(),
      googleBookCoverImageUrl: json['googleBookCoverImageUrl']?.toString(),
      previewLink: json['previewLink']?.toString(),
      infoLink: json['infoLink']?.toString(),
      canonicalLink: json['canonicalLink']?.toString(),
      industryIdentifiers: json['industryIdentifiers'] != null
          ? List<Map<String, String>>.from(
              (json['industryIdentifiers'] as List).map(
                (item) => Map<String, String>.from(item),
              ),
            )
          : null,
      summaryCount: json['summaryCount'] is int ? json['summaryCount'] : 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      summary: Summary.fromJson(json['summary'] ?? {}),
      insights: json['insights'] != null
          ? (json['insights'] as List)
              .map((insight) => Insight.fromJson(insight))
              .toList()
          : null,
      goodreadsBook: json['goodreadsBook'] != null
          ? GoodreadsBook.fromJson(json['goodreadsBook'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleBookId': googleBookId,
      'title': title,
      'subtitle': subtitle,
      'authors': authors,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'categories': categories.map((category) => {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'imageUrl': category.imageUrl,
        'createdAt': category.createdAt,
        'updatedAt': category.updatedAt,
      }).toList(),
      'language': language,
      'pageCount': pageCount,
      'imageUrl': imageUrl,
      'googleBookCoverImageUrl': googleBookCoverImageUrl,
      'previewLink': previewLink,
      'infoLink': infoLink,
      'canonicalLink': canonicalLink,
      'industryIdentifiers': industryIdentifiers,
      'summaryCount': summaryCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'summary': {
        'introduction': summary.introduction,
        'finalThoughts': summary.finalThoughts,
        'content': summary.content,
        'chapters': summary.chapters.map((chapter) => {
          'id': chapter.id,
          'name': chapter.name,
          'content': chapter.content,
          'order': chapter.order,
          'createdAt': chapter.createdAt.toIso8601String(),
          'updatedAt': chapter.updatedAt.toIso8601String(),
        }).toList(),
      },
      'insights': insights?.map((insight) => insight.toJson()).toList(),
      'goodreadsBook': goodreadsBook?.toJson(),
    };
  }
}

// Keep BookWithSummary for backward compatibility - deprecated
@Deprecated('Use BookWithContent instead')
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
    super.googleBookCoverImageUrl,
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
      categories:
          (json['categories'] as List?)
              ?.map((category) => BookCategory.fromJson(category))
              .toList() ??
          [],
      language: json['language']?.toString() ?? 'en',
      pageCount: json['pageCount'] is int ? json['pageCount'] : null,
      imageUrl: json['imageUrl']?.toString(),
      googleBookCoverImageUrl: json['googleBookCoverImageUrl']?.toString(),
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
