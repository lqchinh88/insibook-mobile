import 'book_models.dart';
import '../utils/book_request_extensions.dart';

enum BookRequestStatus {
  pending,
  processing,
  completed,
  failed,
}

enum BookRequestType {
  sync,
  async,
}

class UserBookRequest {
  final String id;
  final BookRequestType requestType;
  final BookRequestStatus status;
  final String? jobId;
  final int progress;
  final String? errorMessage;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BookWithContent book;

  UserBookRequest({
    required this.id,
    required this.requestType,
    required this.status,
    this.jobId,
    required this.progress,
    this.errorMessage,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.book,
  });

  factory UserBookRequest.fromJson(Map<String, dynamic> json) {
    return UserBookRequest(
      id: json['id']?.toString() ?? '',
      requestType: BookRequestTypeExtension.fromApiValue(json['requestType']?.toString()),
      status: BookRequestStatusExtension.fromApiValue(json['status']?.toString()),
      jobId: json['jobId']?.toString(),
      progress: json['progress']?.toInt() ?? 0,
      errorMessage: json['errorMessage']?.toString(),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'].toString())
        : null,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      book: BookWithContent.fromJson(json['book'] ?? {}),
    );
  }

}

class UserBookRequestsResponse {
  final List<UserBookRequest> requests;
  final int total;

  UserBookRequestsResponse({
    required this.requests,
    required this.total,
  });

  factory UserBookRequestsResponse.fromJson(Map<String, dynamic> json) {
    final requestsList = json['requests'] as List<dynamic>? ?? [];
    
    return UserBookRequestsResponse(
      requests: requestsList
          .map((requestJson) => UserBookRequest.fromJson(requestJson))
          .toList(),
      total: json['total']?.toInt() ?? 0,
    );
  }
}