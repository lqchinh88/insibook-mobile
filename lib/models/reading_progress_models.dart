class UpdateReadingProgressDto {
  final double readingPercentage;
  final double? timeSpentMinutes;

  UpdateReadingProgressDto({
    required this.readingPercentage,
    this.timeSpentMinutes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'readingPercentage': readingPercentage,
    };

    if (timeSpentMinutes != null) {
      data['timeSpentMinutes'] = timeSpentMinutes;
    }

    return data;
  }
}

class ReadingProgressResponse {
  final String id;
  final String userId;
  final String bookId;
  final double readingPercentage;
  final double timeSpentMinutes;
  final DateTime lastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadingProgressResponse({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.readingPercentage,
    required this.timeSpentMinutes,
    required this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingProgressResponse.fromJson(Map<String, dynamic> json) {
    return ReadingProgressResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      readingPercentage: (json['readingPercentage'] as num?)?.toDouble() ?? 0.0,
      timeSpentMinutes: (json['timeSpentMinutes'] as num?)?.toDouble() ?? 0.0,
      lastReadAt: DateTime.parse(json['lastReadAt']?.toString() ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

class ReadingProgressWithBook {
  final String id;
  final String userId;
  final String bookId;
  final double readingPercentage;
  final double timeSpentMinutes;
  final DateTime lastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? book;

  ReadingProgressWithBook({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.readingPercentage,
    required this.timeSpentMinutes,
    required this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
    this.book,
  });

  factory ReadingProgressWithBook.fromJson(Map<String, dynamic> json) {
    return ReadingProgressWithBook(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      readingPercentage: (json['readingPercentage'] as num?)?.toDouble() ?? 0.0,
      timeSpentMinutes: (json['timeSpentMinutes'] as num?)?.toDouble() ?? 0.0,
      lastReadAt: DateTime.parse(json['lastReadAt']?.toString() ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      book: json['book'] as Map<String, dynamic>?,
    );
  }
}

class ReadingProgressListResponse {
  final List<ReadingProgressWithBook> progress;
  final int total;
  final int limit;
  final int offset;

  ReadingProgressListResponse({
    required this.progress,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ReadingProgressListResponse.fromJson(Map<String, dynamic> json) {
    final progressList = json['progress'] as List<dynamic>? ?? [];
    return ReadingProgressListResponse(
      progress: progressList
          .map((item) => ReadingProgressWithBook.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReadingStatsResponse {
  final int totalBooksStarted;
  final int totalBooksCompleted;
  final double totalTimeSpentMinutes;
  final double averageReadingProgress;
  final String totalTimeSpentFormatted;

  ReadingStatsResponse({
    required this.totalBooksStarted,
    required this.totalBooksCompleted,
    required this.totalTimeSpentMinutes,
    required this.averageReadingProgress,
    required this.totalTimeSpentFormatted,
  });

  factory ReadingStatsResponse.fromJson(Map<String, dynamic> json) {
    return ReadingStatsResponse(
      totalBooksStarted: (json['totalBooksStarted'] as num?)?.toInt() ?? 0,
      totalBooksCompleted: (json['totalBooksCompleted'] as num?)?.toInt() ?? 0,
      totalTimeSpentMinutes: (json['totalTimeSpentMinutes'] as num?)?.toDouble() ?? 0.0,
      averageReadingProgress: (json['averageReadingProgress'] as num?)?.toDouble() ?? 0.0,
      totalTimeSpentFormatted: json['totalTimeSpentFormatted']?.toString() ?? '0 minutes',
    );
  }
}