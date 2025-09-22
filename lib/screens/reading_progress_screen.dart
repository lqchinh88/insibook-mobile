import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_progress_models.dart';
import '../services/reading_progress_service.dart';
import '../widgets/reading_progress_bar.dart';
import '../utils/result.dart';
import '../providers/language_provider.dart';
import '../lang/app_localizations.dart';

class ReadingProgressScreen extends StatefulWidget {
  const ReadingProgressScreen({super.key});

  @override
  State<ReadingProgressScreen> createState() => _ReadingProgressScreenState();
}

class _ReadingProgressScreenState extends State<ReadingProgressScreen> {
  final ReadingProgressService _progressService = ReadingProgressService();
  List<ReadingProgressWithBook> _progressList = [];
  ReadingStatsResponse? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReadingProgress();
  }

  Future<void> _loadReadingProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load both progress list and stats in parallel
      final results = await Future.wait([
        _progressService.getUserReadingProgress(),
        _progressService.getReadingStats(),
      ]);

      final progressResult = results[0] as ApiResult<ReadingProgressListResponse>;
      final statsResult = results[1] as ApiResult<ReadingStatsResponse>;

      switch (progressResult) {
        case Success<ReadingProgressListResponse, ApiError>():
          _progressList = progressResult.value.progress;
        case Failure<ReadingProgressListResponse, ApiError>():
          _errorMessage = 'Failed to load reading progress: ${progressResult.error.message}';
      }

      switch (statsResult) {
        case Success<ReadingStatsResponse, ApiError>():
          _stats = statsResult.value;
        case Failure<ReadingStatsResponse, ApiError>():
          // Stats failure is not critical, continue without stats
          debugPrint('Failed to load reading stats: ${statsResult.error.message}');
      }
    } catch (e) {
      _errorMessage = 'An error occurred while loading reading progress';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = languageProvider.l10n;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n['reading_progress']!),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorState(l10n)
                  : _buildContent(l10n),
        );
      },
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n['something_went_wrong']!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReadingProgress,
            child: Text(l10n['try_again']!),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_stats != null) ...[
            _buildStatsCard(l10n),
            const SizedBox(height: 24),
          ],
          _buildProgressList(l10n),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AppLocalizations l10n) {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n['reading_statistics']!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n['books_started']!,
                    _stats!.totalBooksStarted.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n['books_completed']!,
                    _stats!.totalBooksCompleted.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    l10n['time_reading']!,
                    _stats!.totalTimeSpentFormatted,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    l10n['avg_progress']!,
                    '${_stats!.averageReadingProgress.toInt()}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressList(AppLocalizations l10n) {
    if (_progressList.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n['no_reading_progress_yet']!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n['start_reading_message']!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n['your_books']!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _progressList.length,
          itemBuilder: (context, index) {
            return _buildProgressItem(_progressList[index], l10n);
          },
        ),
      ],
    );
  }

  Widget _buildProgressItem(ReadingProgressWithBook progress, AppLocalizations l10n) {
    final book = progress.book;
    final title = book?['title']?.toString() ?? 'Unknown Book';
    final authors = book?['authors'] as List<dynamic>?;
    final authorText = authors?.isNotEmpty == true
        ? authors!.map((a) => a.toString()).join(', ')
        : 'Unknown Author';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              authorText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ReadingProgressBar(
              progress: progress.readingPercentage,
              showPercentage: true,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n['time_spent']!}: ${progress.timeSpentMinutes.toInt()} ${l10n['minutes']!}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '${l10n['last_read']!}: ${_formatDate(progress.lastReadAt, l10n)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n['today']!;
    } else if (difference.inDays == 1) {
      return l10n['yesterday']!;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n['days_ago']!}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}