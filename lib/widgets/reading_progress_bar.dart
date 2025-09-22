import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 100.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final bool showPercentage;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 4.0,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage) ...[
          Text(
            '${clampedProgress.toInt()}% Complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedProgress / 100.0,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor ?? theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}