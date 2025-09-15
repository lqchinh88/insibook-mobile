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
      appBar: _buildAppBarWithSwitch(context),
      body: Column(
        children: [
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

  PreferredSizeWidget _buildAppBarWithSwitch(BuildContext context) {
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSegmentedControl(context),
        ),
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