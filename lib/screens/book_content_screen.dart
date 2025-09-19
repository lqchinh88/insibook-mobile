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
      title: Text(
        widget.bookContent.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      actions: [
        _buildContentTypeToggle(context),
      ],
    );
  }

  
  Widget _buildContentTypeToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final String nextTypeText = _selectedContentType == ContentType.summary
            ? (langProvider.l10n['insights'] ?? 'Insights')
            : (langProvider.l10n['summary'] ?? 'Summary');

        return TextButton.icon(
          icon: _selectedContentType == ContentType.summary
              ? const Icon(Icons.lightbulb_outline)
              : const Icon(Icons.book_outlined),
          label: Text(nextTypeText),
          onPressed: widget.bookContent.hasInsights || _selectedContentType == ContentType.insights
              ? () {
                  setState(() {
                    _selectedContentType = _selectedContentType == ContentType.summary
                        ? ContentType.insights
                        : ContentType.summary;
                  });
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: _selectedContentType == ContentType.summary
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
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