import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../theme/app_text_styles.dart';
import '../providers/language_provider.dart';
import '../utils/reading_navigation.dart';
import 'package:provider/provider.dart';

class ChapterOutline extends StatefulWidget {
  final List<SummaryChapter> chapters;
  final BookWithContent book;

  const ChapterOutline({
    super.key,
    required this.chapters,
    required this.book,
  });

  @override
  State<ChapterOutline> createState() => _ChapterOutlineState();
}

class _ChapterOutlineState extends State<ChapterOutline> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<LanguageProvider>(
                      builder: (context, langProvider, child) => Text(
                        langProvider.l10n['chapters'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          // Chapter list
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildChapterList(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildReadButton(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    // Filter top-level chapters (those without parentId)
    final topLevelChapters = widget.chapters.where((chapter) => chapter.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topLevelChapters.map((chapter) => _buildChapterItem(chapter, 0)).toList(),
    );
  }

  Widget _buildChapterItem(SummaryChapter chapter, int indentLevel) {
    final hasChildren = chapter.children.isNotEmpty;
    final isTopLevel = indentLevel == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter item
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16 + (indentLevel * 16),
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isTopLevel
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Chapter name
              Expanded(
                child: Text(
                  chapter.name,
                  style: TextStyle(
                    fontSize: isTopLevel ? 16 : 15,
                    fontWeight: isTopLevel ? FontWeight.w600 : FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: AppTextStyles.fontFamily,
                    height: 1.3,
                  ),
                ),
              ),

              // Children indicator
              if (hasChildren)
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),

        // Child chapters
        if (hasChildren) ...[
          const SizedBox(height: 4),
          ...chapter.children.map((child) => _buildChapterItem(child, indentLevel + 1)),
        ],

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildReadButton() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ReadingNavigation.navigateToReadingScreen(
              context,
              book: widget.book,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            langProvider.l10n['read_summary'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}