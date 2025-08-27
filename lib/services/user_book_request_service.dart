import '../models/user_book_request_models.dart';
import '../utils/book_request_extensions.dart';
import '../utils/result.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class UserBookRequestService {
  // Service-specific constants
  static const String _endpoint = '/users/me/book-requests';
  
  // Get user's book requests with pagination and optional status filtering
  Future<ApiResult<UserBookRequestsResponse>> getUserBookRequests({
    int? limit,
    int? offset,
    BookRequestStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams[ApiConstants.limitParam] = limit;
      if (offset != null) queryParams[ApiConstants.offsetParam] = offset;
      if (status != null) {
        queryParams[ApiConstants.statusParam] = status.apiValue;
      }

      final response = await ApiService.get(
        _endpoint, 
        queryParams: queryParams,
      );
      
      if (response.statusCode == 401) {
        return Failure(ApiError.authentication());
      }
      
      if (response.statusCode == 403) {
        return Failure(ApiError.authorization());
      }
      
      if (response.statusCode >= 500) {
        return Failure(ApiError.server(
          'Server error: ${response.statusCode}',
          response.statusCode,
        ));
      }
      
      if (response.statusCode != 200) {
        return Failure(ApiError.unknown(
          'Request failed with status: ${response.statusCode}',
        ));
      }
      
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return Success(UserBookRequestsResponse.fromJson(jsonData));
      }
      
      return Failure(ApiError.parsing('Failed to parse response data'));
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        return Failure(ApiError.network(e.toString(), e));
      }
      return Failure(ApiError.unknown(e.toString(), e));
    }
  }

  // Get specific book request by ID
  Future<ApiResult<UserBookRequest>> getBookRequest(String requestId) async {
    try {
      final response = await ApiService.get(
        '$_endpoint/$requestId',
      );
      
      if (response.statusCode == 401) {
        return Failure(ApiError.authentication());
      }
      
      if (response.statusCode == 403) {
        return Failure(ApiError.authorization());
      }
      
      if (response.statusCode == 404) {
        return Failure(ApiError.notFound('Book request not found'));
      }
      
      if (response.statusCode >= 500) {
        return Failure(ApiError.server(
          'Server error: ${response.statusCode}',
          response.statusCode,
        ));
      }
      
      if (response.statusCode != 200) {
        return Failure(ApiError.unknown(
          'Request failed with status: ${response.statusCode}',
        ));
      }
      
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return Success(UserBookRequest.fromJson(jsonData));
      }
      
      return Failure(ApiError.parsing('Failed to parse response data'));
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        return Failure(ApiError.network(e.toString(), e));
      }
      return Failure(ApiError.unknown(e.toString(), e));
    }
  }

}