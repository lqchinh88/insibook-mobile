import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // Helper method to get headers with auth token if available
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    
    final token = await AuthService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Helper method to build URI with query parameters (for GET requests)
  static Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString()))
      );
    }
    return uri;
  }

  // GET request with optional query parameters
  static Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams: queryParams);
    final headers = await _getHeaders();
    
    return await http.get(uri, headers: headers);
  }

  // POST request
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // PUT request
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await http.delete(uri, headers: headers);
  }

  // Helper method to handle common response parsing
  static Map<String, dynamic>? parseJsonResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper method to handle list response parsing
  static List<dynamic>? parseJsonListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper method to check if response indicates authentication failure
  static bool isAuthError(http.Response response) {
    return response.statusCode == 401;
  }

  // Helper method to check if response indicates forbidden access
  static bool isForbiddenError(http.Response response) {
    return response.statusCode == 403;
  }

  // Helper method to check if response indicates not found
  static bool isNotFoundError(http.Response response) {
    return response.statusCode == 404;
  }

  // Helper method to check if response indicates server error
  static bool isServerError(http.Response response) {
    return response.statusCode >= 500;
  }

  // Helper method to check if response is successful
  static bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}