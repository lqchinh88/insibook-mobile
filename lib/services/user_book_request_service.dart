import '../models/user_book_request_models.dart';
import 'api_service.dart';

class UserBookRequestService {
  
  // Get user's book requests with pagination and optional status filtering
  Future<UserBookRequestsResponse?> getUserBookRequests({
    int? limit,
    int? offset,
    BookRequestStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) {
        queryParams['status'] = _statusToString(status);
      }

      final response = await ApiService.get('/users/me/book-requests', queryParams: queryParams);
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return UserBookRequestsResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get specific book request by ID
  Future<UserBookRequest?> getBookRequest(String requestId) async {
    try {
      final response = await ApiService.get('/users/me/book-requests/$requestId');
      final jsonData = ApiService.parseJsonResponse(response);
      
      if (jsonData != null) {
        return UserBookRequest.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper method to convert status enum to string
  String _statusToString(BookRequestStatus status) {
    switch (status) {
      case BookRequestStatus.pending:
        return 'pending';
      case BookRequestStatus.processing:
        return 'processing';
      case BookRequestStatus.completed:
        return 'completed';
      case BookRequestStatus.failed:
        return 'failed';
    }
  }
}