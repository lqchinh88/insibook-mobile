import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../utils/result.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  // HTTP client - can be overridden for testing
  static http.Client httpClient = http.Client();

  // Helper method to get headers with auth token if available
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    
    final token = await TokenService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Helper method to build URI with query parameters (for GET requests)
  static Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryParts = <String>[];

      for (final entry in queryParams.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is List) {
          // Handle array parameters like categories[]=value1&categories[]=value2
          for (final item in value) {
            queryParts.add('${Uri.encodeQueryComponent(key)}[]=${Uri.encodeQueryComponent(item.toString())}');
          }
        } else {
          queryParts.add('${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value.toString())}');
        }
      }

      final queryString = queryParts.join('&');
      return Uri.parse('$baseUrl$endpoint?$queryString');
    }
    return uri;
  }

  // GET request with optional query parameters
  static Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams: queryParams);
    final headers = await _getHeaders();
    
    return await httpClient.get(uri, headers: headers);
  }

  // POST request
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    return await httpClient.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // PUT request
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    return await httpClient.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // PATCH request
  static Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    return await httpClient.patch(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    return await httpClient.delete(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
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

  // Result-returning HTTP methods for better error handling
  
  static Future<ApiResult<T>> getWithResult<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await get(endpoint, queryParams: queryParams);
      return _handleResponse(response, parser);
    } catch (e) {
      return Failure(handleException(e));
    }
  }

  static Future<ApiResult<T>> postWithResult<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await post(endpoint, body: body);
      return _handleResponse(response, parser);
    } catch (e) {
      return Failure(handleException(e));
    }
  }

  static Future<ApiResult<T>> putWithResult<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await put(endpoint, body: body);
      return _handleResponse(response, parser);
    } catch (e) {
      return Failure(handleException(e));
    }
  }

  static Future<ApiResult<T>> patchWithResult<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await patch(endpoint, body: body);
      return _handleResponse(response, parser);
    } catch (e) {
      return Failure(handleException(e));
    }
  }

  static Future<ApiResult<T>> deleteWithResult<T>(
    String endpoint, {
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      final response = await delete(endpoint);
      return _handleResponse(response, parser);
    } catch (e) {
      return Failure(handleException(e));
    }
  }

  // Centralized response handling
  static ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        final jsonData = parseJsonResponse(response);
        if (jsonData != null) {
          try {
            return Success(parser(jsonData));
          } catch (e) {
            return Failure(ApiError.parsing('Failed to parse response: ${e.toString()}', e));
          }
        }
        return Failure(ApiError.parsing('Response body is empty or invalid JSON'));

      case 400:
        try {
          final jsonData = json.decode(response.body);
          final message = jsonData['message'] ?? jsonData['description'] ?? 'Bad request';
          return Failure(ApiError.badRequest(message, 400));
        } catch (e) {
          return Failure(ApiError.badRequest('Bad request', 400));
        }

      case 401:
        return Failure(ApiError.authentication());

      case 403:
        return Failure(ApiError.authorization());

      case 404:
        return Failure(ApiError.notFound());

      case 408:
        return Failure(ApiError.timeout());

      case >= 500:
        return Failure(ApiError.server(
          'Server error: ${response.statusCode}',
          response.statusCode,
        ));

      default:
        return Failure(ApiError.unknown(
          'Request failed with status: ${response.statusCode}',
        ));
    }
  }

  // Centralized exception handling
  static ApiError handleException(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') ||
        errorString.contains('handshakeexception') ||
        errorString.contains('connection')) {
      return ApiError.network('Network connection error', error);
    }
    
    if (errorString.contains('timeoutexception') ||
        errorString.contains('timeout')) {
      return ApiError.timeout('Request timed out');
    }
    
    return ApiError.unknown('Unexpected error: ${error.toString()}', error);
  }
}