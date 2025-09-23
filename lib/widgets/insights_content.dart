import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_models.dart';
import '../models/insight.dart';
import '../models/insight_type.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';
import '../screens/auth/login_screen.dart';

class InsightsContent extends StatefulWidget {
  final BookWithContent book;

  const InsightsContent({super.key, required this.book});

  @override
  State<InsightsContent> createState() => _InsightsContentState();
}

class _InsightsContentState extends State<InsightsContent> {
  final BookApiService _bookApiService = BookApiService();

  // Track saved state for each insight
  final Map<String, bool> _insightSavedStates = {};

  @override
  void initState() {
    super.initState();
    // Initialize saved states from the insights
    if (widget.book.insights != null) {
      for (final insight in widget.book.insights!) {
        _insightSavedStates[insight.id] = insight.isSaved ?? false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.book.insights == null || widget.book.insights!.isEmpty) {
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


  Widget _buildInsightsTable(BuildContext context) {
    // Sort insights by order
    final sortedInsights = List<Insight>.from(widget.book.insights!)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: sortedInsights
          .map((insight) => _buildInsightCard(context, insight))
          .toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context, Insight insight) {
    final typeInfo = _getInsightTypeInfo(context, insight.type);

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
          // Bookmark button positioned on top-right
          Positioned(
            right: 16,
            top: 0, // Align with the top border like the type indicator
            child: _buildBookmarkButton(context, insight),
          ),
        ],
      ),
    );
  }

  InsightTypeInfo _getInsightTypeInfo(BuildContext context, InsightType type) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    switch (type) {
      case InsightType.keyIdea:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_key_idea'],
          icon: Icons.lightbulb,
          color: Colors.amber[700]!,
        );
      case InsightType.opinion:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_opinion'],
          icon: Icons.person,
          color: Colors.blue[700]!,
        );
      case InsightType.recommendation:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_recommendation'],
          icon: Icons.thumb_up,
          color: Colors.green[700]!,
        );
      case InsightType.habit:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_habit'],
          icon: Icons.repeat,
          color: Colors.purple[700]!,
        );
      case InsightType.quote:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_quote'],
          icon: Icons.format_quote,
          color: Colors.orange[700]!,
        );
    }
  }

  Widget _buildBookmarkButton(BuildContext context, Insight insight) {
    final isSaved = _insightSavedStates[insight.id] ?? false;

    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        onPressed: () => _toggleBookmark(insight),
        icon: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? Theme.of(context).colorScheme.primary : Colors.grey[600],
        ),
      ),
    );
  }

  Future<void> _toggleBookmark(Insight insight) async {
    // Check authentication first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    // Optimistically update UI
    final currentState = _insightSavedStates[insight.id] ?? false;
    setState(() {
      _insightSavedStates[insight.id] = !currentState;
    });

    // Call API
    final result = await _bookApiService.toggleSavedInsight(insightId: insight.id);

    result.fold(
      (response) {
        // Update with API response
        setState(() {
          _insightSavedStates[insight.id] = response.isSaved;
        });
      },
      (error) {
        // Revert optimistic update on error
        setState(() {
          _insightSavedStates[insight.id] = currentState;
        });

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update insight: ${error.userFriendlyMessage}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
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
