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