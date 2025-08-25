import '../models/book_models.dart';
import 'api_service.dart';

class BookApiService {

  // Get latest books from database
  Future<InternalBookSearchResponse?> getLatestBooks({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await ApiService.get('/books/latest', queryParams: queryParams);
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return InternalBookSearchResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search books in internal database
  Future<InternalBookSearchResponse?> searchInternalBooks({
    String? title,
    String? author,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (author != null && author.isNotEmpty) queryParams['author'] = author;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await ApiService.get('/books/search/internal', queryParams: queryParams);
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return InternalBookSearchResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search books using Google Books API
  Future<BookSearchResponse?> searchGoogleBooks({
    String? title,
    String? author,
    int? maxResults,
    int? startIndex,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (author != null && author.isNotEmpty) queryParams['author'] = author;
      if (maxResults != null) queryParams['maxResults'] = maxResults;
      if (startIndex != null) queryParams['startIndex'] = startIndex;

      final response = await ApiService.get('/books/search/google', queryParams: queryParams);
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return BookSearchResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate book summary asynchronously
  Future<Map<String, dynamic>?> generateSummaryAsync({
    required String googleBookId,
    required String title,
    required List<String> authors,
    required String bookLanguage,
    String? googleBookCoverImageUrl,
    String? publisher,
    List<Map<String, String>>? industryIdentifiers,
    List<String>? categories,
  }) async {
    try {
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
      
      final response = await ApiService.post('/book-summaries/generate-async', body: requestBody);

      if (response.statusCode == 202) {
        return ApiService.parseJsonResponse(response);
      } else {
        return null;
      }
    } catch (e) {
      // Exception generating summary: $e
      return null;
    }
  }

  // Get all book categories
  Future<List<BookCategory>?> getAllCategories() async {
    try {
      final response = await ApiService.get('/books/categories');
      final jsonData = ApiService.parseJsonListResponse(response);
      
      if (jsonData != null) {
        return jsonData.map((category) => BookCategory.fromJson(category)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBookWithSummary({
    required String bookId,
    String summaryLanguage = 'en',
  }) async {
    try {
      final response = await ApiService.get('/books/$bookId', queryParams: {
        'summaryLanguage': summaryLanguage,
      });

      return ApiService.parseJsonResponse(response);
    } catch (e) {
      return null;
    }
  }
}
