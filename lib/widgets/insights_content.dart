import 'package:flutter/material.dart';
import '../models/book_models.dart';
import '../models/insight.dart';
import '../models/insight_type.dart';

class InsightsContent extends StatelessWidget {
  final BookWithContent book;

  const InsightsContent({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.insights == null || book.insights!.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildHeader(context),
        // const SizedBox(height: 16),
        _buildInsightsTable(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No insights available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Insights will appear here when they are generated for this book.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Key Insights',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildInsightsTable(BuildContext context) {
    // Sort insights by order
    final sortedInsights = List<Insight>.from(book.insights!)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: sortedInsights
          .map((insight) => _buildInsightCard(context, insight))
          .toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context, Insight insight) {
    final typeInfo = _getInsightTypeInfo(insight.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Main card content
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12), // Leave space for the type indicator
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: typeInfo.color.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8), // Extra padding to account for the type box
              child: Text(
                insight.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Type indicator positioned on top-left with center aligned to top border
          Positioned(
            left: 16,
            top: 0, // Center of this box will align with the top border
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: typeInfo.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: typeInfo.color.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(typeInfo.icon, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    typeInfo.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InsightTypeInfo _getInsightTypeInfo(InsightType type) {
    switch (type) {
      case InsightType.keyIdea:
        return InsightTypeInfo(
          label: 'Key Idea',
          icon: Icons.lightbulb,
          color: Colors.amber[700]!,
        );
      case InsightType.opinion:
        return InsightTypeInfo(
          label: 'Opinion',
          icon: Icons.person,
          color: Colors.blue[700]!,
        );
      case InsightType.recommendation:
        return InsightTypeInfo(
          label: 'Recommendation',
          icon: Icons.thumb_up,
          color: Colors.green[700]!,
        );
      case InsightType.habit:
        return InsightTypeInfo(
          label: 'Habit',
          icon: Icons.repeat,
          color: Colors.purple[700]!,
        );
      case InsightType.quote:
        return InsightTypeInfo(
          label: 'Quote',
          icon: Icons.format_quote,
          color: Colors.orange[700]!,
        );
    }
  }
}

class InsightTypeInfo {
  final String label;
  final IconData icon;
  final Color color;

  InsightTypeInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}
