import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/book_models.dart';
import '../theme/app_text_styles.dart';

class SummaryContent extends StatelessWidget {
  final BookWithContent book;

  const SummaryContent({
    super.key,
    required this.book,
  });

  // Clean, minimal markdown configuration
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (book.summary.content == null && book.summary.chapters.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content or chapters
          if (book.summary.content != null) ...[
            _buildCleanContent(context, book.summary.content!),
          ] else if (book.summary.chapters.isNotEmpty) ...[
            _buildSectionHeader(context, 'Chapters'),
            const SizedBox(height: 24),
            ...book.summary.chapters.map(
              (chapter) => _buildCleanChapter(context, chapter),
            ),
          ],

          // Final thoughts section
          if (book.summary.finalThoughts != null) ...[
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Final Thoughts'),
            const SizedBox(height: 24),
            _buildCleanContent(context, book.summary.finalThoughts!),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No summary available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The summary content is not available for this book.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: AppTextStyles.fontFamily,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.2,
      ),
    );
  }

  Widget _buildCleanContent(BuildContext context, String content) {
    return MarkdownWidget(
      data: content,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      config: _getCleanMarkdownConfig(context),
    );
  }

  Widget _buildCleanChapter(BuildContext context, SummaryChapter chapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapter.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        MarkdownWidget(
          data: chapter.content,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          config: _getCleanMarkdownConfig(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
