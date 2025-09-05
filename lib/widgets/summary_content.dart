import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import '../models/book_models.dart';

class SummaryContent extends StatelessWidget {
  final BookWithContent book;

  const SummaryContent({
    super.key,
    required this.book,
  });

  // Typography configuration for readable text
  MarkdownConfig _getReadableMarkdownConfig(BuildContext context) => MarkdownConfig(
    configs: [
      // Paragraph configuration for body text
      PConfig(
        textStyle: TextStyle(
          fontSize: 17.0, // 16-18px range for optimal readability
          height: 1.6, // 1.5-1.7x line height for breathing space
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      // Heading configurations
      H1Config(
        style: TextStyle(
          fontSize: 26.0,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.headlineLarge?.color,
        ),
      ),
      H2Config(
        style: TextStyle(
          fontSize: 22.0,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.headlineMedium?.color,
        ),
      ),
      H3Config(
        style: TextStyle(
          fontSize: 19.0,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.headlineSmall?.color,
        ),
      ),
      // Quote styling for emphasis
      BlockquoteConfig(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      // Code styling
      CodeConfig(
        style: TextStyle(
          fontSize: 15.0,
          height: 1.4,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Introduction section
        if (book.summary.introduction != null) ...[
          _buildSectionHeader(context, 'Introduction'),
          const SizedBox(height: 16),
          _buildContentCard(context, book.summary.introduction!),
          const SizedBox(height: 24),
        ],

        // Main content or chapters
        if (book.summary.content != null) ...[
          _buildSectionHeader(context, 'Summary'),
          const SizedBox(height: 16),
          _buildContentCard(context, book.summary.content!),
        ] else if (book.summary.chapters.isNotEmpty) ...[
          _buildSectionHeader(context, 'Chapters'),
          const SizedBox(height: 16),
          ...book.summary.chapters.map((chapter) => _buildChapterCard(context, chapter)),
        ],

        // Final thoughts section
        if (book.summary.finalThoughts != null) ...[
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Final Thoughts'),
          const SizedBox(height: 16),
          _buildContentCard(context, book.summary.finalThoughts!),
        ],
      ],
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
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: MarkdownWidget(
        data: content,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        config: _getReadableMarkdownConfig(context),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, SummaryChapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          MarkdownWidget(
            data: chapter.content,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            config: _getReadableMarkdownConfig(context),
          ),
        ],
      ),
    );
  }
}