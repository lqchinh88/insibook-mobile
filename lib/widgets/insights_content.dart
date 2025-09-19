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
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeInfo.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeInfo.icon, size: 16, color: typeInfo.color),
                const SizedBox(width: 4),
                Text(
                  typeInfo.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: typeInfo.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Text(
              insight.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
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
