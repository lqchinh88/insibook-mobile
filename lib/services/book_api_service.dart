import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_models.dart';

class BookApiService {
  // Update this URL to match your API server
  // For local development: http://localhost:3000
  // For production: https://your-api-domain.com
  static const String baseUrl = 'http://localhost:3000';

  // Get latest books from database
  static Future<InternalBookSearchResponse?> getLatestBooks({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '$baseUrl/books/latest',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InternalBookSearchResponse.fromJson(jsonData);
      } else {
        print('Error fetching latest books: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching latest books: $e');
      return null;
    }
  }

  // Search books in internal database
  static Future<InternalBookSearchResponse?> searchInternalBooks({
    String? title,
    String? author,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (author != null && author.isNotEmpty) queryParams['author'] = author;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '$baseUrl/books/search/internal',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InternalBookSearchResponse.fromJson(jsonData);
      } else {
        print('Error searching internal books: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception searching internal books: $e');
      return null;
    }
  }

  // Search books using Google Books API
  static Future<BookSearchResponse?> searchGoogleBooks({
    String? title,
    String? author,
    int? maxResults,
    int? startIndex,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (author != null && author.isNotEmpty) queryParams['author'] = author;
      if (maxResults != null) queryParams['maxResults'] = maxResults.toString();
      if (startIndex != null) queryParams['startIndex'] = startIndex.toString();

      final uri = Uri.parse(
        '$baseUrl/books/search/google',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BookSearchResponse.fromJson(jsonData);
      } else {
        print('Error searching Google books: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception searching Google books: $e');
      return null;
    }
  }

  // Generate book summary asynchronously
  static Future<Map<String, dynamic>?> generateSummaryAsync({
    required String googleBookId,
    required String title,
    required List<String> authors,
    required String bookLanguage,
    required String summaryLanguage,
    String? googleBookCoverImageUrl,
    String? publisher,
    List<Map<String, String>>? industryIdentifiers,
  }) async {
    try {
      final requestBody = {
        'googleBookId': googleBookId,
        'title': title,
        'authors': authors,
        'bookLanguage': bookLanguage,
        'summaryLanguage': summaryLanguage,
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
      
      final response = await http.post(
        Uri.parse('$baseUrl/book-summaries/generate-async'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 202) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        print('Error generating summary: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception generating summary: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getBookWithSummary({
    required String bookId,
    String summaryLanguage = 'en',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/$bookId?summaryLanguage=$summaryLanguage'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 404) {
        print('Book not found: $bookId');
        return null;
      } else {
        print('Error fetching book details: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception fetching book details: $e');
      return null;
    }
  }
}
