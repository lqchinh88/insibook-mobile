import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';
import '../widgets/summary_content.dart';
import '../widgets/insights_content.dart';
import '../theme/app_text_styles.dart';

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

class _BookContentScreenState extends State<BookContentScreen> {
  ContentType _selectedContentType = ContentType.summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildBookHeader(context),
          _buildSegmentedControl(context),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) => Text(
          _selectedContentType == ContentType.summary
              ? (langProvider.l10n['summary'] ?? 'Summary')
              : (langProvider.l10n['insights'] ?? 'Insights'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildBookHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover with subtle styling
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: widget.bookContent.displayImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      widget.bookContent.displayImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.book,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.book,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
          ),
          const SizedBox(width: 20),

          // Clean book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bookContent.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTextStyles.fontFamily,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                if (widget.bookContent.authors.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'by ${widget.bookContent.authors.join(', ')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppTextStyles.fontFamily,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildContentTypeBadge(context, 'Summary'),
                    if (widget.bookContent.hasInsights) ...[
                      const SizedBox(width: 8),
                      _buildContentTypeBadge(context, 'Insights'),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeBadge(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: AppTextStyles.fontFamily,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return SegmentedButton<ContentType>(
            segments: [
              ButtonSegment<ContentType>(
                value: ContentType.summary,
                label: Text(langProvider.l10n['summary'] ?? 'Summary'),
                icon: const Icon(Icons.article_outlined),
              ),
              ButtonSegment<ContentType>(
                value: ContentType.insights,
                label: Text(langProvider.l10n['insights'] ?? 'Insights'),
                icon: const Icon(Icons.lightbulb_outline),
                enabled: widget.bookContent.hasInsights,
              ),
            ],
            selected: {_selectedContentType},
            onSelectionChanged: (Set<ContentType> newSelection) {
              setState(() {
                _selectedContentType = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
            ),
          );
        },
      ),
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
}