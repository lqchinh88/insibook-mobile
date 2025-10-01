import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/reading_settings_provider.dart';
import '../widgets/reading_progress_indicator.dart';
import '../widgets/chapter_outline_popover.dart';
import '../widgets/insights_content.dart';
import '../services/reading_progress_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/result.dart';

enum ViewMode { chapters, insights }

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
  ViewMode _currentViewMode = ViewMode.chapters;

  List<SummaryChapter> _flattenedChapters = [];
  final Map<String, double> _chapterPositions = {};
  final GlobalKey _markdownKey = GlobalKey();
  bool _isInitialized = false;
  bool _needUpdateProgress = false;
  Timer? _progressUpdateTimer;

  // Track scroll positions for both views
  double _chaptersScrollPosition = 0.0;
  double _insightsScrollPosition = 0.0;

  // Track settings changes for popup
  ReadingFontSize? _initialFontSize;
  ThemeModeOption? _initialTheme;

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
  MarkdownConfig _getCleanMarkdownConfig(BuildContext context, double fontSizeMultiplier) {
    return MarkdownConfig(
      configs: [
        // Clean paragraph styling
        PConfig(
          textStyle: TextStyle(
            fontSize: 18.0 * fontSizeMultiplier,
            height: 1.7,
            fontWeight: FontWeight.w400,
            fontFamily: AppTextStyles.fontFamily,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        // Minimal heading styles
        H1Config(
          style: TextStyle(
            fontSize: 28.0 * fontSizeMultiplier,
            height: 1.3,
            fontWeight: FontWeight.w700,
            fontFamily: AppTextStyles.fontFamily,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        H2Config(
          style: TextStyle(
            fontSize: 24.0 * fontSizeMultiplier,
            height: 1.4,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        H3Config(
          style: TextStyle(
            fontSize: 20.0 * fontSizeMultiplier,
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
            fontSize: 16.0 * fontSizeMultiplier,
            height: 1.4,
            fontFamily: 'monospace',
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

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

    // Only track progress for chapters view
    if (_currentViewMode == ViewMode.chapters) {
      _updateReadingProgress(scrollPosition);
    }
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
                _buildViewModeToggle(context),
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
                  isVisible: _currentViewMode == ViewMode.chapters,
                ),
              ),
            ),

            // Content based on current view mode
            if (_currentViewMode == ViewMode.chapters) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverToBoxAdapter(child: _buildMarkdownContent()),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: _buildInsightsContent(),
                ),
              ),
            ],
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

  Widget _buildInsightsContent() {
    return InsightsContent(book: widget.book);
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
              Consumer<ReadingSettingsProvider>(
                builder: (context, readingSettings, child) {
                  final fontSizeMultiplier = readingSettings.fontSizeMultiplier;
                  return Text(
                    chapter.name,
                    style: TextStyle(
                      fontSize: (chapter.parentId == null ? 28.0 : 24.0) * fontSizeMultiplier,
                      height: 1.3,
                      fontWeight: chapter.parentId == null
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontFamily: AppTextStyles.fontFamily,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
              // Chapter image (if available)
              if (chapter.imageUrl != null && chapter.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    chapter.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              Consumer<ReadingSettingsProvider>(
                builder: (context, readingSettings, child) {
                  return MarkdownWidget(
                    padding: EdgeInsets.zero,
                    data: chapter.content,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    config: _getCleanMarkdownConfig(context, readingSettings.fontSizeMultiplier),
                  );
                },
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
              Consumer<ReadingSettingsProvider>(
                builder: (context, readingSettings, child) {
                  return Text(
                    _getFinalThoughtsTitle(context),
                    style: TextStyle(
                      fontSize: 28.0 * readingSettings.fontSizeMultiplier,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTextStyles.fontFamily,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Consumer<ReadingSettingsProvider>(
                builder: (context, readingSettings, child) {
                  return MarkdownWidget(
                    padding: EdgeInsets.zero,
                    data: widget.book.summary.finalThoughts!,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    config: _getCleanMarkdownConfig(context, readingSettings.fontSizeMultiplier),
                  );
                },
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
      onClose: _closeChapterList,
      onChapterTap: _scrollToChapter,
    );
  }

  void _closeChapterList() {
    _showChapterList.value = false;
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final String nextModeText = _currentViewMode == ViewMode.chapters
            ? langProvider.l10n['insights']
            : langProvider.l10n['chapters'];

        return TextButton.icon(
          icon: _currentViewMode == ViewMode.chapters
              ? const Icon(Icons.lightbulb_outline)
              : const Icon(Icons.book_outlined),
          label: Text(nextModeText),
          onPressed: widget.book.hasInsights ||
                  _currentViewMode == ViewMode.insights
              ? () => _toggleViewMode()
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
    );
  }

  void _toggleViewMode() {
    setState(() {
      // Save current scroll position
      if (_scrollController.hasClients) {
        if (_currentViewMode == ViewMode.chapters) {
          _chaptersScrollPosition = _scrollController.position.pixels;
        } else {
          _insightsScrollPosition = _scrollController.position.pixels;
        }
      }

      // Switch view mode
      _currentViewMode = _currentViewMode == ViewMode.chapters
          ? ViewMode.insights
          : ViewMode.chapters;

      // Reset progress indicator when switching to insights
      if (_currentViewMode == ViewMode.insights) {
        _progressNotifier.value = 0.0;
      }

      // Schedule scroll position restoration after rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
        // Update progress indicator if switching back to chapters
        if (_currentViewMode == ViewMode.chapters && _scrollController.hasClients) {
          final scrollPosition = _scrollController.position.pixels;
          _updateReadingProgress(scrollPosition);
        }
      });
    });
  }

  void _restoreScrollPosition() {
    if (!_scrollController.hasClients) return;

    final targetPosition = _currentViewMode == ViewMode.chapters
        ? _chaptersScrollPosition
        : _insightsScrollPosition;

    final scrollPosition = _scrollController.position;
    final clampedPosition = targetPosition.clamp(0.0, scrollPosition.maxScrollExtent);
    _scrollController.jumpTo(clampedPosition);
  }

  Widget _buildFontSizeSegmentedControl(BuildContext context, ReadingSettingsProvider readingSettingsProvider) {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Small font icon
            Icon(
              Icons.text_fields,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),

            // Slider ruler
            Expanded(
              child: SizedBox(
                height: 40,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: ReadingFontSize.values.indexOf(provider.fontSize).toDouble(),
                    min: 0,
                    max: ReadingFontSize.values.length - 1,
                    divisions: ReadingFontSize.values.length - 1,
                    onChanged: (double newValue) {
                      final newFontSize = ReadingFontSize.values[newValue.round()];
                      provider.setFontSize(newFontSize);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Big font icon
            Icon(
              Icons.text_fields,
              size: 28,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        );
      },
    );
  }

  
  Widget _buildThemeSegmentedControl(BuildContext context, ThemeProvider themeProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeModeOption>(
            segments: const [
              ButtonSegment<ThemeModeOption>(
                value: ThemeModeOption.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment<ThemeModeOption>(
                value: ThemeModeOption.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment<ThemeModeOption>(
                value: ThemeModeOption.system,
                label: Text('System'),
                icon: Icon(Icons.settings_brightness),
              ),
            ],
            selected: {provider.themeMode},
            onSelectionChanged: (Set<ThemeModeOption> newSelection) {
              if (newSelection.isNotEmpty) {
                provider.setThemeMode(newSelection.first);
              }
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            ),
          ),
        );
      },
    );
  }

  void _showOptions() {
    final readingSettingsProvider = Provider.of<ReadingSettingsProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Store initial values to track changes
    _initialFontSize = readingSettingsProvider.fontSize;
    _initialTheme = themeProvider.themeMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Font Size Section - No Title
            _buildFontSizeSegmentedControl(context, readingSettingsProvider),
            const SizedBox(height: 24),

            // Theme Section - Full Width
            Row(
              children: [
                Expanded(
                  child: _buildThemeSegmentedControl(context, themeProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    ).then((_) {
      // Check if any settings changed when popup closes
      final fontSizeChanged = readingSettingsProvider.fontSize != _initialFontSize;
      final themeChanged = themeProvider.themeMode != _initialTheme;

      // Trigger re-render if settings changed
      if (fontSizeChanged || themeChanged) {
        setState(() {});
      }

      // Clear tracking variables when popup closes
      _initialFontSize = null;
      _initialTheme = null;
    });
  }
}
