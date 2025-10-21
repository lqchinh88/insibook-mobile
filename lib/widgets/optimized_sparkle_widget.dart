import 'package:flutter/material.dart';
import '../constants/scroll_animation_constants.dart';

/// Optimized sparkle widget that uses predefined paths instead of real-time drawing
/// Significantly better performance than CustomPainter with shouldRepaint: true
class OptimizedSparkleWidget extends StatefulWidget {
  final double animationProgress;

  const OptimizedSparkleWidget({
    super.key,
    required this.animationProgress,
  });

  @override
  State<OptimizedSparkleWidget> createState() => _OptimizedSparkleWidgetState();
}

class _OptimizedSparkleWidgetState extends State<OptimizedSparkleWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _sparkleControllers;
  late List<Animation<double>> _sparkleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeSparkleAnimations();
  }

  void _initializeSparkleAnimations() {
    _sparkleControllers = List.generate(
      ScrollAnimationConstants.sparkleCount,
      (index) => AnimationController(
        duration: ScrollAnimationConstants.sparkleDuration,
        vsync: this,
      ),
    );

    _sparkleAnimations = _sparkleControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Start animations with staggered delays
    for (int i = 0; i < _sparkleControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _sparkleControllers[i].repeat();
        }
      });
    }
  }

  @override
  void didUpdateWidget(OptimizedSparkleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // React to animation progress changes if needed
  }

  @override
  void dispose() {
    for (final controller in _sparkleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        ScrollAnimationConstants.sparkleCount,
        (index) => _buildSparkle(index),
      ),
    );
  }

  Widget _buildSparkle(int index) {
    final position = ScrollAnimationConstants.sparklePositions[index];

    return AnimatedBuilder(
      animation: _sparkleAnimations[index],
      builder: (context, child) {
        final sparkleProgress = (_sparkleAnimations[index].value + index * 0.2) % 1.0;
        final sparkleSize = ScrollAnimationConstants.minSparkleSize +
                           sparkleProgress * (ScrollAnimationConstants.maxSparkleSize - ScrollAnimationConstants.minSparkleSize);
        final sparkleOpacity = (1.0 - sparkleProgress) * ScrollAnimationConstants.sparkleOpacity;

        return Positioned(
          left: position.dx * ScrollAnimationConstants.bookCoverWidth,
          top: position.dy * ScrollAnimationConstants.bookCoverHeight,
          child: IgnorePointer(
            child: Container(
              width: sparkleSize * 2,
              height: sparkleSize * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: sparkleOpacity),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: sparkleOpacity * 0.5),
                    blurRadius: sparkleSize,
                    spreadRadius: sparkleSize / 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}