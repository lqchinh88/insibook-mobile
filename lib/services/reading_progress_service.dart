import '../models/reading_progress_models.dart';
import '../utils/result.dart';
import 'api_service.dart';

class ReadingProgressService {
  /// Update or create reading progress for a specific book
  /// Only call when crossing 10% milestones (0%, 10%, 20%, etc.)
  Future<ApiResult<ReadingProgressResponse>> updateReadingProgress({
    required String bookId,
    required double readingPercentage,
    double? timeSpentMinutes,
  }) {
    final requestBody = UpdateReadingProgressDto(
      readingPercentage: readingPercentage,
      timeSpentMinutes: timeSpentMinutes,
    );

    return ApiService.putWithResult(
      '/books/$bookId/reading-progress',
      body: requestBody.toJson(),
      parser: ReadingProgressResponse.fromJson,
    );
  }

  /// Get current reading progress for a specific book
  Future<ApiResult<ReadingProgressResponse?>> getReadingProgress({
    required String bookId,
  }) async {
    try {
      final response = await ApiService.get('/books/$bookId/reading-progress');

      switch (response.statusCode) {
        case 200:
          final jsonData = ApiService.parseJsonResponse(response);
          if (jsonData != null) {
            return Success(ReadingProgressResponse.fromJson(jsonData));
          }
          return Failure(ApiError.parsing('Failed to parse reading progress'));

        case 204:
          // No reading progress found - this is expected for new books
          return Success(null);

        case 401:
          return Failure(ApiError.authentication());
        case 403:
          return Failure(ApiError.authorization());
        case 404:
          return Failure(ApiError.notFound('Book not found'));
        case >= 500:
          return Failure(ApiError.server());
        default:
          return Failure(ApiError.unknown());
      }
    } catch (e) {
      return Failure(ApiService.handleException(e));
    }
  }

  /// Get all reading progress records for the current user
  Future<ApiResult<ReadingProgressListResponse>> getUserReadingProgress({
    int? limit,
    int? offset,
  }) {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    return ApiService.getWithResult(
      '/user/reading-progress',
      queryParams: queryParams,
      parser: ReadingProgressListResponse.fromJson,
    );
  }

  /// Get reading statistics for the current user
  Future<ApiResult<ReadingStatsResponse>> getReadingStats() {
    return ApiService.getWithResult(
      '/user/reading-stats',
      parser: ReadingStatsResponse.fromJson,
    );
  }
}

/// Utility class for tracking reading progress milestones
class ReadingProgressTracker {
  double _lastReportedPercentage = 0.0;
  DateTime _sessionStartTime = DateTime.now();
  Duration _accumulatedTime = Duration.zero;
  bool _isReading = false;

  /// Check if the new percentage crosses a 10% milestone
  bool shouldUpdateProgress(double currentPercentage) {
    final currentMilestone = _getMilestone(currentPercentage);
    final lastMilestone = _getMilestone(_lastReportedPercentage);

    return currentMilestone != lastMilestone && currentMilestone > lastMilestone;
  }

  /// Get the milestone percentage (0, 10, 20, 30, etc.)
  double getMilestoneToReport(double currentPercentage) {
    return _getMilestone(currentPercentage);
  }

  /// Mark that progress has been reported for the current milestone
  void markProgressReported(double reportedPercentage) {
    _lastReportedPercentage = reportedPercentage;
  }

  /// Start tracking reading time
  void startReadingSession() {
    if (!_isReading) {
      _sessionStartTime = DateTime.now();
      _isReading = true;
    }
  }

  /// Stop tracking reading time and accumulate the session duration
  void pauseReadingSession() {
    if (_isReading) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime);
      _accumulatedTime += sessionDuration;
      _isReading = false;
    }
  }

  /// Get accumulated reading time in minutes and reset the counter
  double getAndResetAccumulatedMinutes() {
    // Include current session if still reading
    if (_isReading) {
      final currentSessionDuration = DateTime.now().difference(_sessionStartTime);
      _accumulatedTime += currentSessionDuration;
      _sessionStartTime = DateTime.now(); // Reset session start
    }

    final minutes = _accumulatedTime.inMinutes.toDouble();
    _accumulatedTime = Duration.zero;
    return minutes;
  }

  /// Reset all tracking data (useful when switching books)
  void reset() {
    _lastReportedPercentage = 0.0;
    _sessionStartTime = DateTime.now();
    _accumulatedTime = Duration.zero;
    _isReading = false;
  }

  /// Initialize with existing progress (when loading a book that already has progress)
  void initializeWithExistingProgress(double existingPercentage) {
    _lastReportedPercentage = _getMilestone(existingPercentage);
  }

  /// Helper method to calculate the milestone (rounded down to nearest 10%)
  double _getMilestone(double percentage) {
    if (percentage >= 100.0) return 100.0;
    if (percentage <= 0.0) return 0.0;
    return (percentage ~/ 10) * 10.0;
  }
}