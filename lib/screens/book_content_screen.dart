import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../models/reading_progress_models.dart';
import '../providers/language_provider.dart';
import '../widgets/summary_content.dart';
import '../widgets/insights_content.dart';
import '../widgets/reading_progress_indicator.dart';
import '../services/reading_progress_service.dart';
import '../utils/result.dart';

enum ContentType { summary, insights }

class BookContentScreen extends StatefulWidget {
  final BookWithContent bookContent;

  const BookContentScreen({
    super.key,
    required this.bookContent,
  });

  @override
  State<BookContentScreen> createState() => _BookContentScreenState();
}

class _BookContentScreenState extends State<BookContentScreen> with WidgetsBindingObserver {
  ContentType _selectedContentType = ContentType.summary;
  final ScrollController _scrollController = ScrollController();
  final ReadingProgressService _readingProgressService = ReadingProgressService();
  final ReadingProgressTracker _progressTracker = ReadingProgressTracker();
  bool _isInitialized = false;
  double _currentReadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _initializeReadingProgress();
    _scheduleScrollRestorationIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressTracker.pauseReadingSession();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _progressTracker.startReadingSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _progressTracker.pauseReadingSession();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBarWithSwitch(context),
      body: Column(
        children: [
          // Progress bar strip - only show for Summary content
          ReadingProgressIndicator(
            progress: _currentReadingProgress,
            isVisible: _selectedContentType == ContentType.summary,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBarWithSwitch(BuildContext context) {
    return AppBar(
      title: Text(
        widget.bookContent.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      actions: [
        _buildContentTypeToggle(context),
      ],
    );
  }

  
  Widget _buildContentTypeToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final String nextTypeText = _selectedContentType == ContentType.summary
            ? langProvider.l10n['insights']
            : langProvider.l10n['summary'];

        return TextButton.icon(
          icon: _selectedContentType == ContentType.summary
              ? const Icon(Icons.lightbulb_outline)
              : const Icon(Icons.book_outlined),
          label: Text(nextTypeText),
          onPressed: widget.bookContent.hasInsights || _selectedContentType == ContentType.insights
              ? () {
                  setState(() {
                    _selectedContentType = _selectedContentType == ContentType.summary
                        ? ContentType.insights
                        : ContentType.summary;

                    // Reset progress indicator when switching to Insights
                    if (_selectedContentType == ContentType.insights) {
                      _currentReadingProgress = 0.0;
                    } else {
                      // Restore progress when switching back to Summary
                      final progress = widget.bookContent.readingProgress;
                      if (progress != null) {
                        _currentReadingProgress = progress.readingPercentage;
                      }
                    }
                  });
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: _selectedContentType == ContentType.summary
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedContentType) {
      case ContentType.summary:
        return SummaryContent(book: widget.bookContent);
      case ContentType.insights:
        return InsightsContent(book: widget.bookContent);
    }
  }

  /// Initialize reading progress tracking using data from book API response
  void _initializeReadingProgress() {
    if (_isInitialized) return;

    // Initialize progress tracker with existing progress if available
    final progress = widget.bookContent.readingProgress;
    if (progress != null) {
      _progressTracker.initializeWithExistingProgress(progress.readingPercentage);
      // Initialize visual progress bar with existing progress
      _currentReadingProgress = progress.readingPercentage;
    }

    _progressTracker.startReadingSession();
    _isInitialized = true;
  }

  /// Handle scroll events and track reading progress
  void _onScroll() {
    if (!_isInitialized || !_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position;
    if (scrollPosition.maxScrollExtent <= 0) return;

    // Calculate reading percentage (0-100)
    final currentPercentage = (scrollPosition.pixels / scrollPosition.maxScrollExtent) * 100;
    final clampedPercentage = currentPercentage.clamp(0.0, 100.0);

    // Update visual progress indicator in real-time for Summary content
    if (_selectedContentType == ContentType.summary && _currentReadingProgress != clampedPercentage) {
      setState(() {
        _currentReadingProgress = clampedPercentage;
      });
    }

    // Check if we should update progress (crossed a 10% milestone)
    if (_progressTracker.shouldUpdateProgress(clampedPercentage)) {
      _updateReadingProgress(clampedPercentage);
    }
  }

  /// Update reading progress to backend when milestone is reached
  Future<void> _updateReadingProgress(double currentPercentage) async {
    final milestonePercentage = _progressTracker.getMilestoneToReport(currentPercentage);
    final timeSpentMinutes = _progressTracker.getAndResetAccumulatedMinutes();

    try {
      final result = await _readingProgressService.updateReadingProgress(
        bookId: widget.bookContent.id,
        readingPercentage: milestonePercentage,
        timeSpentMinutes: timeSpentMinutes > 0 ? timeSpentMinutes : null,
      );

      switch (result) {
        case Success<ReadingProgressResponse, ApiError>():
          _progressTracker.markProgressReported(milestonePercentage);
        case Failure<ReadingProgressResponse, ApiError>():
          // Silent failure - don't show error to user, but log for debugging
          debugPrint('Failed to update reading progress: ${result.error.message}');
      }
    } catch (e) {
      // Silent failure - don't show error to user
      debugPrint('Exception updating reading progress: $e');
    }
  }

  /// Schedule scroll restoration if needed based on reading progress from API
  void _scheduleScrollRestorationIfNeeded() {
    final progress = widget.bookContent.readingProgress;

    // Only restore for Summary content with incomplete progress
    if (progress != null &&
        _selectedContentType == ContentType.summary &&
        _progressTracker.shouldRestoreFromApiProgress(progress.readingPercentage)) {

      // Wait for widget layout completion before attempting scroll restoration
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition(progress.readingPercentage);
      });
    }
  }

  /// Restore scroll position based on reading percentage from API
  void _restoreScrollPosition(double apiPercentage) {
    try {
      if (!_scrollController.hasClients) {
        debugPrint('ScrollController not ready for restoration');
        return;
      }

      final scrollPosition = _scrollController.position;
      if (scrollPosition.maxScrollExtent <= 0) {
        debugPrint('Content not yet rendered, maxScrollExtent: ${scrollPosition.maxScrollExtent}');
        return;
      }

      // Calculate target scroll position from percentage
      final targetPosition = (apiPercentage / 100.0) * scrollPosition.maxScrollExtent;
      final clampedPosition = targetPosition.clamp(0.0, scrollPosition.maxScrollExtent);

      // Jump to the calculated position
      _scrollController.jumpTo(clampedPosition);

      // Mark restoration as completed to prevent re-triggering
      _progressTracker.markRestorationCompleted();

      debugPrint('Restored scroll position to ${clampedPosition.toInt()}px (${apiPercentage.toStringAsFixed(1)}%)');
    } catch (e) {
      debugPrint('Failed to restore scroll position: $e');
    }
  }
}