// Generic Result type for better error handling
sealed class Result<T, E> {
  const Result();
}

class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}

// Extension methods for easier usage
extension ResultExtensions<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
  
  T? get value => switch (this) {
    Success<T, E> success => success.value,
    Failure<T, E> _ => null,
  };
  
  E? get error => switch (this) {
    Success<T, E> _ => null,
    Failure<T, E> failure => failure.error,
  };
  
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return switch (this) {
      Success<T, E> success => onSuccess(success.value),
      Failure<T, E> failure => onFailure(failure.error),
    };
  }
}

// API-specific error types
enum ApiErrorType {
  network,
  authentication,
  authorization,
  badRequest,
  server,
  parsing,
  notFound,
  timeout,
  unknown,
}

class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiError.network([String? message, dynamic originalError]) => ApiError(
    type: ApiErrorType.network,
    message: message ?? 'Network connection error',
    originalError: originalError,
  );

  factory ApiError.authentication([String? message]) => ApiError(
    type: ApiErrorType.authentication,
    message: message ?? 'Authentication failed',
    statusCode: 401,
  );

  factory ApiError.authorization([String? message]) => ApiError(
    type: ApiErrorType.authorization,
    message: message ?? 'Access denied',
    statusCode: 403,
  );

  factory ApiError.badRequest([String? message, int? statusCode]) => ApiError(
    type: ApiErrorType.badRequest,
    message: message ?? 'Bad request',
    statusCode: statusCode ?? 400,
  );

  factory ApiError.server([String? message, int? statusCode]) => ApiError(
    type: ApiErrorType.server,
    message: message ?? 'Server error occurred',
    statusCode: statusCode ?? 500,
  );

  factory ApiError.parsing([String? message, dynamic originalError]) => ApiError(
    type: ApiErrorType.parsing,
    message: message ?? 'Failed to parse response data',
    originalError: originalError,
  );

  factory ApiError.notFound([String? message]) => ApiError(
    type: ApiErrorType.notFound,
    message: message ?? 'Resource not found',
    statusCode: 404,
  );

  factory ApiError.timeout([String? message]) => ApiError(
    type: ApiErrorType.timeout,
    message: message ?? 'Request timeout',
    statusCode: 408,
  );

  factory ApiError.unknown([String? message, dynamic originalError]) => ApiError(
    type: ApiErrorType.unknown,
    message: message ?? 'Unknown error occurred',
    originalError: originalError,
  );

  String get userFriendlyMessage {
    switch (type) {
      case ApiErrorType.network:
        return 'Please check your internet connection and try again.';
      case ApiErrorType.authentication:
        return 'Please sign in again to continue.';
      case ApiErrorType.authorization:
        return 'You don\'t have permission to access this resource.';
      case ApiErrorType.badRequest:
        return message;
      case ApiErrorType.server:
        return 'Server is currently unavailable. Please try again later.';
      case ApiErrorType.parsing:
        return 'Something went wrong while processing the response.';
      case ApiErrorType.notFound:
        return 'The requested resource was not found.';
      case ApiErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ApiErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() => 'ApiError(type: $type, message: $message, statusCode: $statusCode)';
}

// Type alias for common Result usage
typedef ApiResult<T> = Result<T, ApiError>;