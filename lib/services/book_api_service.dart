import '../models/book_models.dart';
import '../models/bookmark_models.dart';
import '../models/saved_insight_models.dart';
import '../models/async_summary_response.dart';
import '../utils/result.dart';
import 'api_service.dart';

class BookApiService {
  // Get latest books from database
  Future<ApiResult<InternalBookSearchResponse>> getLatestBooks({
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

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
    double? minStarRating,
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (title != null && title.isNotEmpty) queryParams['title'] = title;
    if (author != null && author.isNotEmpty) queryParams['author'] = author;
    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['categories'] = categoryIds;
    }
    if (minStarRating != null) queryParams['minRating'] = minStarRating;
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
  Future<ApiResult<List<BookCategory>>> getAllCategories() async {
    try {
      final response = await ApiService.get('/books/categories');

      switch (response.statusCode) {
        case 200:
          final jsonData = ApiService.parseJsonListResponse(response);
          if (jsonData != null) {
            final categories = jsonData
                .map((category) => BookCategory.fromJson(category))
                .toList();
            return Success(categories);
          }
          return Failure(ApiError.parsing('Failed to parse categories'));

        case 401:
          return Failure(ApiError.authentication());
        case 403:
          return Failure(ApiError.authorization());
        case 404:
          return Failure(ApiError.notFound());
        case >= 500:
          return Failure(ApiError.server());
        default:
          return Failure(ApiError.unknown());
      }
    } catch (e) {
      return Failure(ApiService.handleException(e));
    }
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
}
