import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../providers/language_provider.dart';

class SummaryReaderScreen extends StatefulWidget {
  final BookWithSummary bookDetails;

  const SummaryReaderScreen({super.key, required this.bookDetails});

  @override
  State<SummaryReaderScreen> createState() => _SummaryReaderScreenState();
}

class _SummaryReaderScreenState extends State<SummaryReaderScreen> {
  
  // Typography configuration for readable text
  MarkdownConfig get _readableMarkdownConfig => MarkdownConfig(
    configs: [
      // Paragraph configuration for body text
      PConfig(
        textStyle: TextStyle(
          fontSize: 17.0, // 16-18px range for optimal readability
          height: 1.6, // 1.5-1.7x line height for breathing space
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.bodyLarge?.color, // Use theme color for proper contrast
        ),
      ),
      // Heading configurations
      H1Config(
        style: TextStyle(
          fontSize: 26.0,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.headlineLarge?.color, // Use theme color
        ),
      ),
      H2Config(
        style: TextStyle(
          fontSize: 22.0,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.headlineMedium?.color, // Use theme color
        ),
      ),
      H3Config(
        style: TextStyle(
          fontSize: 19.0,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.headlineSmall?.color, // Use theme color
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
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, // Use theme background
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, langProvider, child) => Text(
            langProvider.l10n['summary'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Increased margins for better reading
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Row(
                children: [
                  // Book cover
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: widget.bookDetails.displayImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.bookDetails.displayImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(
                              Icons.book,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookDetails.title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Georgia', // Serif for book title
                            color: Theme.of(context).textTheme.titleLarge?.color,
                            height: 1.3,
                          ),
                        ),
                        if (widget.bookDetails.authors.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'by ${widget.bookDetails.authors.join(', ')}',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'SF Pro Text', // Clean sans-serif
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary Content
            if (widget.bookDetails.summary.content != null) ...[
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia', // Serif font for book-like feel
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24), // Increased padding for better reading
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
                  data: widget.bookDetails.summary.content!,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  config: _readableMarkdownConfig,
                ),
              ),
            ],

            // TODO: Chapters implementation kept for future use
            // Uncomment this section to switch back to chapters display
            /*
            // Chapters
            Text(
              'Chapters',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia', // Serif font for book-like feel
                color: Theme.of(context).textTheme.headlineLarge?.color,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            ...widget.bookDetails.summary.chapters
                .map(
                  (chapter) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24), // Increased padding for better reading
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
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Georgia', // Serif font for headings
                            color: Theme.of(context).textTheme.headlineMedium?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: MarkdownWidget(
                            data: chapter.content,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            config: _readableMarkdownConfig,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            */

            const SizedBox(height: 24),

            // Final Thoughts
            if (widget.bookDetails.summary.finalThoughts != null) ...[
              Text(
                'Final Thoughts',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia', // Serif font for book-like feel
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24), // Increased padding for better reading
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
                  data: widget.bookDetails.summary.finalThoughts!,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  config: _readableMarkdownConfig,
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
