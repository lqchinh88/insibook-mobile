import 'package:flutter/foundation.dart';
import '../models/book_models.dart';
import '../models/resume_reading_models.dart';
import '../models/bookmark_models.dart';
import '../models/saved_insight_models.dart';
import '../models/async_summary_response.dart';
import '../models/curated_collection_models.dart';
import '../utils/result.dart';
import 'api_service.dart';

class BookApiService {
  // Get hero book for homepage
  Future<ApiResult<InternalBookItem>> getHeroBook() {
    return ApiService.getWithResult(
      '/books/hero',
      parser: (json) => InternalBookItem.fromJson(json['data']),
    );
  }

  // Get latest books from database
  Future<ApiResult<InternalBookSearchResponse>> getLatestBooks({
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortDirection != null && sortDirection.isNotEmpty) queryParams['sortDirection'] = sortDirection;

    return ApiService.getWithResult(
      '/books/latest',
      queryParams: queryParams,
      parser: InternalBookSearchResponse.fromJson,
    );
  }

  // Search books in internal database
  Future<ApiResult<InternalBookSearchResponse>> searchInternalBooks({
    String? title,
    String? author,
    List<String>? categoryIds,
    List<String>? collectionIds,
    double? minStarRating,
    String? sortBy,
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (title != null && title.isNotEmpty) queryParams['title'] = title;
    if (author != null && author.isNotEmpty) queryParams['author'] = author;
    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['categories'] = categoryIds;
    }
    if (collectionIds != null && collectionIds.isNotEmpty) {
      queryParams['collections'] = collectionIds;
    }
    if (minStarRating != null) queryParams['minRating'] = minStarRating;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return ApiService.getWithResult(
      '/books/search/internal',
      queryParams: queryParams,
      parser: InternalBookSearchResponse.fromJson,
    );
  }

  // Search books using Google Books API
  Future<ApiResult<BookSearchResponse>> searchGoogleBooks({
    String? title,
    String? author,
    int? maxResults,
    int? startIndex,
  }) {
    final queryParams = <String, dynamic>{};
    if (title != null && title.isNotEmpty) queryParams['title'] = title;
    if (author != null && author.isNotEmpty) queryParams['author'] = author;
    if (maxResults != null) queryParams['maxResults'] = maxResults;
    if (startIndex != null) queryParams['startIndex'] = startIndex;

    return ApiService.getWithResult(
      '/books/search/google',
      queryParams: queryParams,
      parser: BookSearchResponse.fromJson,
    );
  }

  // Generate book summary asynchronously
  Future<ApiResult<AsyncSummaryResponse>> generateSummaryAsync({
    required String googleBookId,
    required String title,
    required List<String> authors,
    required String bookLanguage,
    String? googleBookCoverImageUrl,
    String? publisher,
    List<Map<String, String>>? industryIdentifiers,
    List<String>? categories,
  }) {
    final requestBody = {
      'googleBookId': googleBookId,
      'title': title,
      'authors': authors,
      'bookLanguage': bookLanguage,
    };

    if (googleBookCoverImageUrl != null) {
      requestBody['googleBookCoverImageUrl'] = googleBookCoverImageUrl;
    }

    if (publisher != null) {
      requestBody['publisher'] = publisher;
    }

    if (industryIdentifiers != null) {
      requestBody['industryIdentifiers'] = industryIdentifiers;
    }

    if (categories != null) {
      requestBody['categories'] = categories;
    }

    return ApiService.postWithResult(
      '/book-summaries/generate-async',
      body: requestBody,
      parser: AsyncSummaryResponse.fromJson,
    );
  }

  // Get all book categories
  Future<ApiResult<List<BookCategory>>> getAllCategories() {
    return ApiService.getWithResult(
      '/books/categories',
      parser: (json) => (json['data'] as List)
          .map((category) => BookCategory.fromJson(category))
          .toList(),
    );
  }

  // Get books by category
  Future<ApiResult<InternalBookSearchResponse>> getBooksByCategory({
    required String categoryId,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortDirection != null && sortDirection.isNotEmpty) queryParams['sortDirection'] = sortDirection;

    return ApiService.getWithResult(
      '/books/category/$categoryId',
      queryParams: queryParams,
      parser: InternalBookSearchResponse.fromJson,
    );
  }

  // Get books by collection
  Future<ApiResult<InternalBookSearchResponse>> getBooksByCollection({
    required String collectionId,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortDirection != null && sortDirection.isNotEmpty) queryParams['sortDirection'] = sortDirection;

    return ApiService.getWithResult(
      '/books/collection/$collectionId',
      queryParams: queryParams,
      parser: InternalBookSearchResponse.fromJson,
    );
  }

  /// Get book with both summary and insights content
  Future<ApiResult<BookWithContent>> getBookWithContent({
    required String bookId,
    String summaryLanguage = 'en',
  }) {
    return ApiService.getWithResult(
      '/books/$bookId',
      queryParams: {'summaryLanguage': summaryLanguage},
      parser: BookWithContent.fromJson,
    );
  }

  /// Get book with summary (deprecated - use getBookWithContent instead)
  @Deprecated('Use getBookWithContent instead for unified content retrieval')
  Future<ApiResult<BookWithSummary>> getBookWithSummary({
    required String bookId,
    String summaryLanguage = 'en',
  }) {
    return ApiService.getWithResult(
      '/books/$bookId',
      queryParams: {'summaryLanguage': summaryLanguage},
      parser: BookWithSummary.fromJson,
    );
  }

  /// Get user bookmarks
  Future<ApiResult<BookmarkedBooksResponse>> getUserBookmarks({
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return ApiService.getWithResult(
      '/bookmarks',
      queryParams: queryParams,
      parser: BookmarkedBooksResponse.fromJson,
    );
  }

  /// Toggle bookmark status for a book
  Future<ApiResult<BookmarkResponse>> toggleBookmark({required String bookId}) {
    return ApiService.postWithResult(
      '/bookmarks/$bookId/toggle',
      parser: BookmarkResponse.fromJson,
    );
  }

  /// Toggle saved status for an insight
  Future<ApiResult<SavedInsightResponse>> toggleSavedInsight({
    required String insightId,
  }) {
    return ApiService.postWithResult(
      '/saved-insights/$insightId/toggle',
      parser: SavedInsightResponse.fromJson,
    );
  }

  /// Save an insight
  Future<ApiResult<SavedInsightResponse>> saveInsight({
    required String insightId,
  }) {
    return ApiService.postWithResult(
      '/saved-insights/$insightId',
      parser: SavedInsightResponse.fromJson,
    );
  }

  /// Remove a saved insight
  Future<ApiResult<SavedInsightResponse>> removeSavedInsight({
    required String insightId,
  }) {
    return ApiService.deleteWithResult(
      '/saved-insights/$insightId',
      parser: SavedInsightResponse.fromJson,
    );
  }

  /// Get user saved insights
  Future<ApiResult<SavedInsightsListResponse>> getUserSavedInsights({
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return ApiService.getWithResult(
      '/saved-insights',
      queryParams: queryParams,
      parser: SavedInsightsListResponse.fromJson,
    );
  }

  /// Get books user is currently reading (resume reading section)
  Future<ApiResult<ResumeReadingResponse>> getResumeReadingBooks({
    int? limit,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;

    return ApiService.getWithResult(
      '/books/resume-reading',
      queryParams: queryParams,
      parser: ResumeReadingResponse.fromJson,
    );
  }

  /// Get books from custom endpoint for homepage sections
  Future<ApiResult<InternalBookSearchResponse>> getCustomSectionBooks({
    required String endpoint,
    Map<String, dynamic>? parameters,
    String? sortBy,
    String? sortDirection,
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (parameters != null) queryParams.addAll(parameters);
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortDirection != null && sortDirection.isNotEmpty) queryParams['sortDirection'] = sortDirection;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return ApiService.getWithResult(
      endpoint,
      queryParams: queryParams,
      parser: InternalBookSearchResponse.fromJson,
    );
  }

  /// Get a curated collection by ID
  Future<ApiResult<CuratedCollection>> getCuratedCollection({
    required String collectionId,
  }) {
    return ApiService.getWithResult(
      '/admin/curated-book-collections/$collectionId',
      parser: (json) => CuratedCollection.fromJson(json['data']),
    );
  }

  /// Get curated collection details with books (public endpoint)
  Future<ApiResult<CuratedCollection>> getCuratedCollectionDetails({
    required String collectionId,
    String? language,
  }) {
    final queryParams = <String, dynamic>{};
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
    }

    return ApiService.getWithResult(
      '/curated-collections/$collectionId',
      queryParams: queryParams,
      parser: CuratedCollection.fromJson,
    );
  }

  /// Increment read count for a book. Call this when a user starts reading a book.
  /// Works for both authenticated users and guests.
  Future<ApiResult<int>> incrementReadCount({
    required String bookId,
  }) {
    debugPrint('📚 Calling POST /books/$bookId/read to increment read count');
    return ApiService.postWithResult(
      '/books/$bookId/read',
      parser: (json) => json['data']['readCount'] as int,
    );
  }
}
