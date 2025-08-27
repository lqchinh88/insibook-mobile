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
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams[ApiConstants.limitParam] = limit;
    if (offset != null) queryParams[ApiConstants.offsetParam] = offset;
    if (status != null) {
      queryParams[ApiConstants.statusParam] = status.apiValue;
    }

    return ApiService.getWithResult(
      _endpoint,
      queryParams: queryParams,
      parser: UserBookRequestsResponse.fromJson,
    );
  }

  // Get specific book request by ID
  Future<ApiResult<UserBookRequest>> getBookRequest(String requestId) {
    return ApiService.getWithResult(
      '$_endpoint/$requestId',
      parser: UserBookRequest.fromJson,
    );
  }

}