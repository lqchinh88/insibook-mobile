import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class StarRatingFilter extends StatelessWidget {
  final double? selectedRating;
  final ValueChanged<double?> onRatingChanged;

  const StarRatingFilter({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>().l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n['minimum_rating'],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              _buildRatingChip(null, l10n['all'], context),
              _buildRatingChip(3.0, '3+', context),
              _buildRatingChip(4.0, '4+', context),
              _buildRatingChip(4.5, '4.5+', context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingChip(double? rating, String label, BuildContext context) {
    final isSelected = selectedRating == rating;

    return GestureDetector(
      onTap: () {
        onRatingChanged(isSelected ? null : rating);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rating != null) ...[
              Icon(
                Icons.star,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : Colors.amber[600],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              rating != null ? '${rating.toString()}+' : label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}