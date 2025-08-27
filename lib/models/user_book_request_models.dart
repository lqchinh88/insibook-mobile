import 'book_models.dart';

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
  final BookWithSummary book;

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
      requestType: _parseRequestType(json['requestType']?.toString()),
      status: _parseRequestStatus(json['status']?.toString()),
      jobId: json['jobId']?.toString(),
      progress: json['progress']?.toInt() ?? 0,
      errorMessage: json['errorMessage']?.toString(),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'].toString())
        : null,
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      book: BookWithSummary.fromJson(json['book'] ?? {}),
    );
  }

  static BookRequestType _parseRequestType(String? type) {
    switch (type) {
      case 'sync':
        return BookRequestType.sync;
      case 'async':
        return BookRequestType.async;
      default:
        return BookRequestType.async;
    }
  }

  static BookRequestStatus _parseRequestStatus(String? status) {
    switch (status) {
      case 'pending':
        return BookRequestStatus.pending;
      case 'processing':
        return BookRequestStatus.processing;
      case 'completed':
        return BookRequestStatus.completed;
      case 'failed':
        return BookRequestStatus.failed;
      default:
        return BookRequestStatus.pending;
    }
  }

  bool get isCompleted => status == BookRequestStatus.completed;
  bool get isProcessing => status == BookRequestStatus.processing;
  bool get hasFailed => status == BookRequestStatus.failed;
  bool get isPending => status == BookRequestStatus.pending;

  String get statusDisplayName {
    switch (status) {
      case BookRequestStatus.pending:
        return 'Pending';
      case BookRequestStatus.processing:
        return 'Processing';
      case BookRequestStatus.completed:
        return 'Completed';
      case BookRequestStatus.failed:
        return 'Failed';
    }
  }

  String get requestTypeDisplayName {
    switch (requestType) {
      case BookRequestType.sync:
        return 'Synchronous';
      case BookRequestType.async:
        return 'Asynchronous';
    }
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