import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class ChapterOutlinePopover extends StatelessWidget {
  final List<SummaryChapter> chapters;
  final BookWithContent book;
  final Function(SummaryChapter)? onChapterTap;
  final VoidCallback onClose;
  final Offset targetPosition;
  final Size targetSize;

  const ChapterOutlinePopover({
    super.key,
    required this.chapters,
    required this.book,
    required this.onClose,
    required this.targetPosition,
    required this.targetSize,
    this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Calculate popover position
    final popoverWidth = 300.0;
    final maxHeight = mediaQuery.size.height * 0.7;

    // Position below the target button
    final left = targetPosition.dx - (popoverWidth / 2) + (targetSize.width / 2);
    final adjustedLeft = left.clamp(16.0, mediaQuery.size.width - popoverWidth - 16);

    // Arrow position (center of target button)
    final arrowX = targetPosition.dx + (targetSize.width / 2);
    final relativeArrowX = arrowX - adjustedLeft;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Popover
          Positioned(
            left: adjustedLeft,
            top: targetPosition.dy + targetSize.height + 8,
            child: Column(
              children: [
                // Arrow
                CustomPaint(
                  size: const Size(20, 10),
                  painter: ArrowPainter(
                    color: theme.colorScheme.surface,
                    arrowPosition: relativeArrowX,
                  ),
                ),

                // Popover content
                Container(
                  width: popoverWidth,
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Consumer<LanguageProvider>(
                                builder: (context, langProvider, child) => Text(
                                  langProvider.l10n['chapters'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontFamily: AppTextStyles.fontFamily,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              onPressed: onClose,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chapter list
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: _buildChapterList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    // Filter top-level chapters (those without parentId)
    final topLevelChapters = chapters.where((chapter) => chapter.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topLevelChapters.map((chapter) => _buildChapterItem(chapter, 0)).toList(),
    );
  }

  Widget _buildChapterItem(SummaryChapter chapter, int indentLevel) {
    final hasChildren = chapter.children.isNotEmpty;
    final isTopLevel = indentLevel == 0;

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter item
          InkWell(
            onTap: () {
              // Always call onChapterTap if provided, then always close
              onChapterTap?.call(chapter);
              onClose();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: (indentLevel * 16) + 8,
                top: 8,
                bottom: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                color: isTopLevel
                    ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Chapter name
                  Expanded(
                    child: Text(
                      chapter.name,
                      style: TextStyle(
                        fontSize: isTopLevel ? 14 : 13,
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
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                ],
              ),
            ),
          ),

          // Child chapters
          if (hasChildren) ...[
            const SizedBox(height: 2),
            ...chapter.children.map((child) => _buildChapterItem(child, indentLevel + 1)),
          ],

          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final double arrowPosition;

  ArrowPainter({
    required this.color,
    required this.arrowPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create arrow pointing up
    final arrowWidth = 20.0;
    final arrowHeight = 10.0;
    final arrowTipX = arrowPosition.clamp(arrowWidth / 2, size.width - arrowWidth / 2);

    path.moveTo(arrowTipX - arrowWidth / 2, arrowHeight);
    path.lineTo(arrowTipX, 0);
    path.lineTo(arrowTipX + arrowWidth / 2, arrowHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ArrowPainter &&
        (oldDelegate.color != color || oldDelegate.arrowPosition != arrowPosition);
  }
}