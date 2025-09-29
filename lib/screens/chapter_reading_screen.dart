import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../widgets/reading_progress_indicator.dart';
import '../widgets/chapter_outline_popover.dart';
import '../services/reading_progress_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/result.dart';

class ChapterReadingScreen extends StatefulWidget {
  final BookWithContent book;
  final SummaryChapter? initialChapter;

  const ChapterReadingScreen({super.key, required this.book, this.initialChapter});

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
  final GlobalKey _menuButtonKey = GlobalKey();

  List<SummaryChapter> _flattenedChapters = [];
  final Map<String, double> _chapterPositions = {};
  final GlobalKey _markdownKey = GlobalKey();
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

    // Calculate positions after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateChapterPositions();
      _scrollToInitialChapter();
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
    if (_markdownKey.currentContext == null) return;

    final RenderBox renderBox =
        _markdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset markdownOffset = renderBox.localToGlobal(Offset.zero);

    for (final chapter in _flattenedChapters) {
      // Find the chapter widget by its key
      final chapterWidgetKey = ValueKey(chapter.id);
      final chapterContext = _findContextByKey(chapterWidgetKey);

      if (chapterContext != null) {
        final chapterRenderBox = chapterContext.findRenderObject() as RenderBox;
        final chapterOffset = chapterRenderBox.localToGlobal(Offset.zero);
        final relativePosition = chapterOffset.dy - markdownOffset.dy;

        _chapterPositions[chapter.id] = relativePosition;
      }
    }
  }

  BuildContext? _findContextByKey(ValueKey key) {
    if (_markdownKey.currentContext == null) return null;

    BuildContext? foundContext;
    _markdownKey.currentContext!.visitChildElements((element) {
      if (element.widget.key == key) {
        foundContext = element;
        return;
      }
    });

    return foundContext;
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

  void _scrollToInitialChapter() {
    if (widget.initialChapter != null) {
      // Wait a bit for positions to be calculated and layout to complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollToChapter(widget.initialChapter!);
        }
      });
    }
  }

  void _scrollToChapter(SummaryChapter chapter) {
    // Recalculate positions to ensure accuracy
    _calculateChapterPositions();

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
    // Recalculate positions when the widget rebuilds (e.g., after content loads)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateChapterPositions();
    });

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
                  key: _menuButtonKey,
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
    return Column(
      key: _markdownKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildChapterWidgets(),
    );
  }

  List<Widget> _buildChapterWidgets() {
    final widgets = <Widget>[];

    for (final chapter in _flattenedChapters) {
      widgets.add(
        Container(
          key: ValueKey(chapter.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter header
              Text(
                chapter.name,
                style: TextStyle(
                  fontSize: chapter.parentId == null ? 28.0 : 24.0,
                  height: 1.3,
                  fontWeight: chapter.parentId == null
                      ? FontWeight.w700
                      : FontWeight.w600,
                  fontFamily: AppTextStyles.fontFamily,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              // Add horizontal line only for chapters with children
              if (chapter.children.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 8),
              ],
              // Chapter content
              MarkdownWidget(
                padding: EdgeInsets.zero,
                data: chapter.content,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                config: _getCleanMarkdownConfig(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    // Add Final Thoughts section if it exists
    if (widget.book.summary.finalThoughts != null &&
        widget.book.summary.finalThoughts!.isNotEmpty) {
      widgets.add(
        Container(
          key: const ValueKey('final_thoughts'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFinalThoughtsTitle(context),
                style: TextStyle(
                  fontSize: 28.0,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTextStyles.fontFamily,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              MarkdownWidget(
                padding: EdgeInsets.zero,
                data: widget.book.summary.finalThoughts!,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                config: _getCleanMarkdownConfig(context),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildChapterListOverlay() {
    // Get menu button position
    final renderBox = _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return ChapterOutlinePopover(
      chapters: widget.book.summary.chapters,
      book: widget.book,
      targetPosition: position,
      targetSize: size,
      onClose: _toggleChapterList,
      onChapterTap: _scrollToChapter,
    );
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
