import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_insight_models.dart';
import '../models/insight_type.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../services/book_api_service.dart';
import '../utils/result.dart';
import '../screens/book_details_screen.dart';
import '../models/book_models.dart';
import '../widgets/book_cover_image.dart';

class SavedInsightCard extends StatefulWidget {
  final SavedInsightWithBook insight;
  final VoidCallback? onRemoved;

  const SavedInsightCard({
    super.key,
    required this.insight,
    this.onRemoved,
  });

  @override
  State<SavedInsightCard> createState() => _SavedInsightCardState();
}

class _SavedInsightCardState extends State<SavedInsightCard> {
  final BookApiService _bookApiService = BookApiService();
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getInsightTypeInfo(context, widget.insight.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Main card content
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12), // Leave space for badges
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Insight content on top
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Text(
                    widget.insight.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                // Book details at bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: _buildBookInfo(context),
                ),
              ],
            ),
          ),
          // Type indicator positioned on top-left
          Positioned(
            left: 16,
            top: 0,
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
          // Remove bookmark button positioned on top-right
          Positioned(
            right: 16,
            top: 0,
            child: _buildRemoveButton(context),
          ),
        ],
      ),
    );
  }


  Widget _buildBookInfo(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToBookDetails(),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          // Book cover
          SizedBox(
            width: 40,
            height: 56,
            child: BookCoverImage(
              imageUrl: widget.insight.book.imageUrl,
              width: 40,
              height: 56,
            ),
          ),
          const SizedBox(width: 12),
          // Book details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.insight.book.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.insight.book.authors.join(', '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Navigation arrow
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      return const SizedBox.shrink();
    }

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
        onPressed: _isRemoving ? null : () => _removeInsight(),
        icon: _isRemoving
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(
                Icons.bookmark,
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }

  void _navigateToBookDetails() {
    // Convert SavedInsightBook to InternalBookItem for navigation
    final bookItem = InternalBookItem(
      id: widget.insight.book.id,
      googleBookId: '', // Not available from saved insight
      title: widget.insight.book.title,
      authors: widget.insight.book.authors,
      categories: [], // Not available from saved insight
      language: widget.insight.language,
      summaryCount: 0, // Not available from saved insight
      createdAt: widget.insight.createdAt.toIso8601String(),
      updatedAt: widget.insight.createdAt.toIso8601String(),
      imageUrl: widget.insight.book.imageUrl,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: bookItem),
      ),
    );
  }

  Future<void> _removeInsight() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || _isRemoving) {
      return;
    }

    setState(() {
      _isRemoving = true;
    });

    final result = await _bookApiService.removeSavedInsight(
      insightId: widget.insight.id,
    );

    if (mounted) {
      setState(() {
        _isRemoving = false;
      });

      result.fold(
        (response) {
          // Success - notify parent to remove from list
          widget.onRemoved?.call();
        },
        (error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove insight: ${error.userFriendlyMessage}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    }
  }

  InsightTypeInfo _getInsightTypeInfo(BuildContext context, InsightType type) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    switch (type) {
      case InsightType.keyIdea:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_key_idea'] ?? 'Key Idea',
          icon: Icons.lightbulb,
          color: Colors.amber[700]!,
        );
      case InsightType.opinion:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_opinion'] ?? 'Opinion',
          icon: Icons.person,
          color: Colors.blue[700]!,
        );
      case InsightType.recommendation:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_recommendation'] ?? 'Recommendation',
          icon: Icons.thumb_up,
          color: Colors.green[700]!,
        );
      case InsightType.habit:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_habit'] ?? 'Habit',
          icon: Icons.repeat,
          color: Colors.purple[700]!,
        );
      case InsightType.quote:
        return InsightTypeInfo(
          label: langProvider.l10n['insight_quote'] ?? 'Quote',
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