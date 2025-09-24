import 'package:flutter/material.dart';

class ReadingProgressIndicator extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;
  final bool isVisible;

  const ReadingProgressIndicator({
    super.key,
    required this.progressNotifier,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (context, progress, child) {
          return Container(
            height: 3.0,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: CustomPaint(
              painter: ProgressBarPainter(
                progress: progress,
                progressColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color progressColor;

  ProgressBarPainter({
    required this.progress,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    final progressWidth = size.width * (progress / 100.0).clamp(0.0, 1.0);
    final rect = Rect.fromLTWH(0, 0, progressWidth, size.height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return progress != oldDelegate.progress || progressColor != oldDelegate.progressColor;
  }
}