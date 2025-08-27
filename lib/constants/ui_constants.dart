import 'package:flutter/material.dart';

class UIConstants {
  // Book Cover Dimensions
  static const double bookCoverWidth = 60.0;
  static const double bookCoverHeight = 80.0;
  static const double bookCoverRadius = 8.0;
  
  // Card Layout
  static const double cardBorderRadius = 12.0;
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenPadding = EdgeInsets.all(32.0);
  
  // Spacing
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 8.0;
  static const double largeSpacing = 16.0;
  static const double xLargeSpacing = 24.0;
  static const double xxLargeSpacing = 32.0;
  
  // Progress Indicator
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorStrokeWidth = 2.0;
  
  // Status Badge
  static const EdgeInsets statusBadgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const double statusBadgeRadius = 12.0;
  static const double statusBadgeFontSize = 12.0;
  
  // Empty State Icons
  static const double emptyStateIconSize = 80.0;
  
  // Error Container
  static const EdgeInsets errorContainerPadding = EdgeInsets.all(8.0);
  static const double errorContainerRadius = 8.0;
  static const double errorIconSize = 16.0;
  static const double errorFontSize = 12.0;
  
  // Icon Sizes
  static const double smallIconSize = 14.0;
  static const double mediumIconSize = 20.0;
  static const double largeIconSize = 32.0;
  
  // Opacity Values
  static const double lowOpacity = 0.1;
  static const double mediumOpacity = 0.3;
  static const double highOpacity = 0.8;
}

class AppColors {
  // Status Colors
  static const Color pendingColor = Colors.orange;
  static const Color processingColor = Colors.blue;
  static const Color completedColor = Colors.green;
  static const Color failedColor = Colors.red;
  
  // Neutral Colors
  static final Color lightGrey = Colors.grey[300]!;
  static final Color mediumGrey = Colors.grey[600]!;
  static final Color darkGrey = Colors.grey[700]!;
  
  // Error Colors
  static final Color errorBackground = Colors.red.withValues(alpha: UIConstants.lowOpacity);
  static final Color errorBorder = Colors.red.withValues(alpha: UIConstants.mediumOpacity);
  static final Color errorText = Colors.red[800]!;
}

class AppStrings {
  // Library Screen
  static const String libraryTitle = 'Library';
  static const String signInToViewLibrary = 'Sign in to view your library';
  static const String libraryDescription = 'Your book requests and progress will appear here once you\'re signed in.';
  static const String libraryEmpty = 'Your library is empty';
  static const String libraryEmptyDescription = 'You haven\'t requested any book summaries yet. Start exploring books and request summaries to see them here.';
  static const String errorLoadingLibrary = 'Error loading library';
  static const String retryButton = 'Retry';
  static const String refreshingProfile = 'Refreshing profile...';
  
  // Filters
  static const String filterByStatus = 'Filter by status';
  static const String allRequests = 'All Requests';
  static const String pending = 'Pending';
  static const String processing = 'Processing'; 
  static const String completed = 'Completed';
  static const String failed = 'Failed';
  
  // Status Display Names
  static const String pendingStatus = 'Pending';
  static const String processingStatus = 'Processing';
  static const String completedStatus = 'Completed';
  static const String failedStatus = 'Failed';
  
  // Progress
  static const String progress = 'Progress';
  
  // Time Formatting
  static const String daysAgo = 'd ago';
  static const String hoursAgo = 'h ago';
  static const String minutesAgo = 'm ago';
  static const String justNow = 'Just now';
  static const String requested = 'Requested';
  static const String completedAt = 'Completed';
  
  // Generic
  static const String unknownError = 'Unknown error occurred';
  static const String failedToLoad = 'Failed to load book requests';
}