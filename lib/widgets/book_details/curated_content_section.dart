import 'package:flutter/material.dart';
import '../../models/curated_collection_models.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// Widget for displaying curated content sections (reason, takeaways, prerequisites)
class CuratedContentSection extends StatelessWidget {
  final CuratedCollectionItem collectionItem;

  const CuratedContentSection({
    super.key,
    required this.collectionItem,
  });

  @override
  Widget build(BuildContext context) {
    final reasonForInclusion = _getReasonForInclusion();
    final keyTakeaways = _getKeyTakeaways();
    final prerequisites = _getPrerequisites();

    return Column(
      children: [
        // Reason for Inclusion
        _buildContentBox(
          context: context,
          icon: Icons.star_rounded,
          title: context.read<LanguageProvider>().l10n['why_this_book'],
          content: reasonForInclusion,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          iconColor: Theme.of(context).colorScheme.primary,
        ),

        const SizedBox(height: 16),

        // Key Takeaways
        _buildContentBox(
          context: context,
          icon: Icons.lightbulb_rounded,
          title: context.read<LanguageProvider>().l10n['key_takeaways'],
          content: keyTakeaways,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.1),
          borderColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          iconColor: Theme.of(context).colorScheme.secondary,
        ),

        const SizedBox(height: 16),

        // Prerequisites
        _buildContentBox(
          context: context,
          icon: Icons.school_rounded,
          title: context.read<LanguageProvider>().l10n['prerequisites'],
          content: prerequisites,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
          borderColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
          iconColor: Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );
  }

  String _getReasonForInclusion() {
    return collectionItem.reasonForInclusion?.isNotEmpty == true
        ? collectionItem.reasonForInclusion!
        : 'No specific reason provided for this book\'s inclusion.';
  }

  String _getKeyTakeaways() {
    return collectionItem.keyTakeaways?.isNotEmpty == true
        ? collectionItem.keyTakeaways!
        : 'No key takeaways available for this book.';
  }

  String _getPrerequisites() {
    return collectionItem.prerequisites?.isNotEmpty == true
        ? collectionItem.prerequisites!
        : 'No specific prerequisites for reading this book.';
  }

  Widget _buildContentBox({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}