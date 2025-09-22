import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../models/reading_progress_models.dart';
import '../providers/language_provider.dart';
import '../widgets/summary_content.dart';
import '../widgets/insights_content.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _initializeReadingProgress();
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
            ? (langProvider.l10n['insights'] ?? 'Insights')
            : (langProvider.l10n['summary'] ?? 'Summary');

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

  /// Initialize reading progress tracking for this book
  Future<void> _initializeReadingProgress() async {
    if (_isInitialized) return;

    try {
      final result = await _readingProgressService.getReadingProgress(
        bookId: widget.bookContent.id,
      );

      switch (result) {
        case Success<ReadingProgressResponse?, ApiError>():
          final progressResponse = result.value;
          if (progressResponse != null) {
            _progressTracker.initializeWithExistingProgress(progressResponse.readingPercentage);
          }
          _progressTracker.startReadingSession();
          _isInitialized = true;
        case Failure<ReadingProgressResponse?, ApiError>():
          // Initialize with fresh tracking even if API call fails
          _progressTracker.startReadingSession();
          _isInitialized = true;
      }
    } catch (e) {
      // Initialize with fresh tracking even if error occurs
      _progressTracker.startReadingSession();
      _isInitialized = true;
    }
  }

  /// Handle scroll events and track reading progress
  void _onScroll() {
    if (!_isInitialized || !_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position;
    if (scrollPosition.maxScrollExtent <= 0) return;

    // Calculate reading percentage (0-100)
    final currentPercentage = (scrollPosition.pixels / scrollPosition.maxScrollExtent) * 100;
    final clampedPercentage = currentPercentage.clamp(0.0, 100.0);

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
}