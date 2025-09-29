import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../widgets/reading_progress_indicator.dart';
import '../services/reading_progress_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/result.dart';

class ChapterReadingScreen extends StatefulWidget {
  final BookWithContent book;

  const ChapterReadingScreen({super.key, required this.book});

  @override
  State<ChapterReadingScreen> createState() => _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends State<ChapterReadingScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  final ReadingProgressTracker _progressTracker = ReadingProgressTracker();
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showChapterList = ValueNotifier<bool>(false);

  List<SummaryChapter> _flattenedChapters = [];
  final Map<String, double> _chapterPositions = {};
  bool _isInitialized = false;
  bool _needUpdateProgress = false;
  Timer? _progressUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _flattenedChapters = _flattenChapters(widget.book.summary.chapters);
    _initializeReadingProgress();
    _calculateChapterPositions();

    // Recalculate positions after first frame to get accurate measurements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateChapterPositions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressTracker.pauseReadingSession();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _progressUpdateTimer?.cancel();
    _progressNotifier.dispose();
    _showChapterList.dispose();
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

  List<SummaryChapter> _flattenChapters(List<SummaryChapter> chapters) {
    final flattened = <SummaryChapter>[];
    for (final chapter in chapters) {
      flattened.add(chapter);
      if (chapter.children.isNotEmpty) {
        flattened.addAll(_flattenChapters(chapter.children));
      }
    }
    return flattened;
  }

  String _concatenateChaptersMarkdown(
    List<SummaryChapter> chapters,
    BuildContext context,
  ) {
    final buffer = StringBuffer();

    for (final chapter in chapters) {
      // Determine header level based on hierarchy
      final headerLevel = chapter.parentId == null ? 1 : 2;
      final header = '#' * headerLevel;

      // Add chapter header
      buffer.writeln('$header ${chapter.name}');
      buffer.writeln(); // Add empty line after header

      // Add chapter content
      buffer.writeln(chapter.content);
      buffer.writeln(); // Add empty line after content
    }

    // Add Final Thoughts section if it exists
    if (widget.book.summary.finalThoughts != null &&
        widget.book.summary.finalThoughts!.isNotEmpty) {
      buffer.writeln(); // Add spacing before Final Thoughts
      buffer.writeln('# ${_getFinalThoughtsTitle(context)}');
      buffer.writeln(); // Add empty line after header
      buffer.writeln(widget.book.summary.finalThoughts!);
    }

    return buffer.toString().trim();
  }

  String _getFinalThoughtsTitle(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    return langProvider.l10n['final_thoughts'];
  }

  // Clean, minimal markdown configuration (reused from SummaryContent)
  MarkdownConfig _getCleanMarkdownConfig(BuildContext context) =>
      MarkdownConfig(
        configs: [
          // Clean paragraph styling
          PConfig(
            textStyle: TextStyle(
              fontSize: 18.0,
              height: 1.7,
              fontWeight: FontWeight.w400,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Minimal heading styles
          H1Config(
            style: TextStyle(
              fontSize: 28.0,
              height: 1.3,
              fontWeight: FontWeight.w700,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          H2Config(
            style: TextStyle(
              fontSize: 24.0,
              height: 1.4,
              fontWeight: FontWeight.w600,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          H3Config(
            style: TextStyle(
              fontSize: 20.0,
              height: 1.4,
              fontWeight: FontWeight.w600,
              fontFamily: AppTextStyles.fontFamily,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Clean quote styling
          BlockquoteConfig(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          // Minimal code styling
          CodeConfig(
            style: TextStyle(
              fontSize: 16.0,
              height: 1.4,
              fontFamily: 'monospace',
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      );

  void _calculateChapterPositions() {
    double position = 0;

    // Start position after app bar and progress bar
    position += kToolbarHeight + 24; // App bar + progress bar + initial padding

    // Estimate position for each chapter in the single markdown document
    // This is an approximation since the actual height depends on rendered markdown
    for (final chapter in _flattenedChapters) {
      _chapterPositions[chapter.id] = position;

      // Estimate chapter height based on content length and structure
      final estimatedHeight = _estimateChapterHeightInMarkdown(chapter);
      position += estimatedHeight;
    }
  }

  double _estimateChapterHeightInMarkdown(SummaryChapter chapter) {
    double height = 0;

    // Chapter header height (H1 or H2)
    final headerHeight = chapter.parentId == null
        ? 56
        : 48; // H1: 28px * 2, H2: 24px * 2
    height += headerHeight;

    // Content height - estimate based on markdown content
    // Markdown will have more spacing and varied element heights
    final contentLines = (chapter.content.length / 40)
        .ceil(); // ~40 chars per line at 18px
    final contentHeight = contentLines * 31; // 18px font * 1.7 line height
    height += contentHeight;

    // Add spacing for markdown elements (paragraphs, lists, etc.)
    height += 16; // Extra spacing for markdown formatting

    // Additional padding between chapters
    height += 32;

    return height;
  }

  void _handleScroll() {
    final scrollPosition = _scrollController.offset;
    _updateReadingProgress(scrollPosition);
  }

  void _updateReadingProgress(double scrollPosition) {
    if (_flattenedChapters.isEmpty) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final progress = scrollPosition / maxScroll;
    final progressPercentage = (progress * 100).clamp(0.0, 100.0);

    _progressNotifier.value = progress;

    // Only update progress at 10% milestones
    final milestoneProgress = (progressPercentage / 10).round() * 10;
    if (milestoneProgress != _lastMilestone) {
      _needUpdateProgress = true;
      _lastMilestone = milestoneProgress.round();

      // Debounce progress updates
      _progressUpdateTimer?.cancel();
      _progressUpdateTimer = Timer(const Duration(seconds: 2), () {
        if (_needUpdateProgress) {
          _syncReadingProgress(milestoneProgress.toDouble());
          _needUpdateProgress = false;
        }
      });
    }
  }

  int _lastMilestone = 0;

  Future<void> _syncReadingProgress(double percentage) async {
    try {
      // TODO: Implement proper time tracking
      final timeSpent = 0.0;
      await _readingProgressService.updateReadingProgress(
        bookId: widget.book.id,
        readingPercentage: percentage.toDouble(),
        timeSpentMinutes: timeSpent,
      );
    } catch (e) {
      // Silently handle progress sync errors
      debugPrint('Error syncing reading progress: $e');
    }
  }

  Future<void> _initializeReadingProgress() async {
    if (_isInitialized) return;

    try {
      final result = await _readingProgressService.getReadingProgress(
        bookId: widget.book.id,
      );

      if (result is Success && result.value != null) {
        final progress = result.value!;
        _progressTracker.startReadingSession();

        // Restore scroll position based on reading progress
        if (progress.readingPercentage > 0) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final targetPosition = (progress.readingPercentage / 100) * maxScroll;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              targetPosition,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing reading progress: $e');
      _isInitialized = true;
    }
  }

  void _toggleChapterList() {
    _showChapterList.value = !_showChapterList.value;
  }

  void _scrollToChapter(SummaryChapter chapter) {
    final position = _chapterPositions[chapter.id] ?? 0;
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _showChapterList.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: _showChapterList,
        builder: (context, showChapterList, child) {
          return Stack(
            children: [
              // Chapter content
              _buildChapterContent(),
              // Chapter list overlay
              if (showChapterList) _buildChapterListOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapterContent() {
    return Stack(
      children: [
        // Static scroll view - never changes structure
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Main app bar with space for overlay headers
            SliverAppBar(
              pinned: true,
              title: Consumer<LanguageProvider>(
                builder: (context, langProvider, child) => Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: _toggleChapterList,
                  tooltip: 'Chapter list',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showOptions,
                  tooltip: 'Options',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: ReadingProgressIndicator(
                  progressNotifier: _progressNotifier,
                  isVisible: true,
                ),
              ),
            ),

            // Single markdown content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(child: _buildMarkdownContent()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkdownContent() {
    final markdownContent = _concatenateChaptersMarkdown(
      _flattenedChapters,
      context,
    );

    return MarkdownWidget(
      padding: EdgeInsets.zero,
      data: markdownContent,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      config: _getCleanMarkdownConfig(context),
    );
  }

  Widget _buildChapterListOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleChapterList,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.75,
                child: GestureDetector(
                  onTap: () {}, // Prevent closing when tapping inside
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Chapters',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppTextStyles.fontFamily,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _toggleChapterList,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: _buildChapterListItems(
                              widget.book.summary.chapters,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChapterListItems(
    List<SummaryChapter> chapters, {
    int level = 0,
  }) {
    final items = <Widget>[];

    for (final chapter in chapters) {
      items.add(
        Padding(
          padding: EdgeInsets.only(left: level * 16.0, bottom: 8),
          child: InkWell(
            onTap: () => _scrollToChapter(chapter),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chapter.name,
                      style: TextStyle(
                        fontSize: 14 + (2 - level * 0.5),
                        fontWeight: FontWeight.w400,
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (chapter.children.isNotEmpty) {
        items.addAll(
          _buildChapterListItems(chapter.children, level: level + 1),
        );
      }
    }

    return items;
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Change font size'),
              onTap: () {
                Navigator.pop(context);
                _showFontSizeOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Theme'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement theme switching
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmark current chapter'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement bookmarking
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Font Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [14, 16, 18, 20, 22].map((size) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement font size change
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$size'),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
