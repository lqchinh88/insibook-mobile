class AsyncSummaryResponse {
  final String requestId;
  final String summaryJobId;
  final String? coverJobId;
  final String status;
  final String message;

  AsyncSummaryResponse({
    required this.requestId,
    required this.summaryJobId,
    this.coverJobId,
    required this.status,
    required this.message,
  });

  factory AsyncSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AsyncSummaryResponse(
      requestId: json['requestId']?.toString() ?? '',
      summaryJobId: json['summaryJobId']?.toString() ?? '',
      coverJobId: json['coverJobId']?.toString(),
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'summaryJobId': summaryJobId,
      'coverJobId': coverJobId,
      'status': status,
      'message': message,
    };
  }
}