import 'package:flutter/material.dart';
import '../models/reading_progress_models.dart';
import '../services/reading_progress_service.dart';
import '../widgets/reading_progress_bar.dart';
import '../utils/result.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Progress'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
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
            'Something went wrong',
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
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_stats != null) ...[
            _buildStatsCard(),
            const SizedBox(height: 24),
          ],
          _buildProgressList(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Books Started',
                    _stats!.totalBooksStarted.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Books Completed',
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
                    'Time Reading',
                    _stats!.totalTimeSpentFormatted,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Progress',
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

  Widget _buildProgressList() {
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
              'No reading progress yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading some books to see your progress here!',
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
          'Your Books',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _progressList.length,
          itemBuilder: (context, index) {
            return _buildProgressItem(_progressList[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProgressItem(ReadingProgressWithBook progress) {
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
                  'Time spent: ${progress.timeSpentMinutes.toInt()} minutes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Last read: ${_formatDate(progress.lastReadAt)}',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}