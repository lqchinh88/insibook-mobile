import 'package:flutter/material.dart';
import '../models/user_book_request_models.dart';
import '../constants/ui_constants.dart';

extension BookRequestStatusExtension on BookRequestStatus {
  String get apiValue {
    switch (this) {
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

  String get displayName {
    switch (this) {
      case BookRequestStatus.pending:
        return AppStrings.pendingStatus;
      case BookRequestStatus.processing:
        return AppStrings.processingStatus;
      case BookRequestStatus.completed:
        return AppStrings.completedStatus;
      case BookRequestStatus.failed:
        return AppStrings.failedStatus;
    }
  }

  Color get color {
    switch (this) {
      case BookRequestStatus.pending:
        return AppColors.pendingColor;
      case BookRequestStatus.processing:
        return AppColors.processingColor;
      case BookRequestStatus.completed:
        return AppColors.completedColor;
      case BookRequestStatus.failed:
        return AppColors.failedColor;
    }
  }

  IconData get icon {
    switch (this) {
      case BookRequestStatus.pending:
        return Icons.schedule;
      case BookRequestStatus.processing:
        return Icons.sync;
      case BookRequestStatus.completed:
        return Icons.check_circle;
      case BookRequestStatus.failed:
        return Icons.error;
    }
  }

  static BookRequestStatus fromApiValue(String? value) {
    switch (value) {
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
}

extension BookRequestTypeExtension on BookRequestType {
  String get apiValue {
    switch (this) {
      case BookRequestType.sync:
        return 'sync';
      case BookRequestType.async:
        return 'async';
    }
  }

  String get displayName {
    switch (this) {
      case BookRequestType.sync:
        return 'Synchronous';
      case BookRequestType.async:
        return 'Asynchronous';
    }
  }

  static BookRequestType fromApiValue(String? value) {
    switch (value) {
      case 'sync':
        return BookRequestType.sync;
      case 'async':
        return BookRequestType.async;
      default:
        return BookRequestType.async;
    }
  }
}

extension UserBookRequestExtension on UserBookRequest {
  bool get isCompleted => status == BookRequestStatus.completed;
  bool get isProcessing => status == BookRequestStatus.processing;
  bool get hasFailed => status == BookRequestStatus.failed;
  bool get isPending => status == BookRequestStatus.pending;
}

extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}${AppStrings.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${AppStrings.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${AppStrings.minutesAgo}';
    } else {
      return AppStrings.justNow;
    }
  }
}