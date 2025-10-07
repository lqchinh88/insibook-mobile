import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum BookRevealState {
  initial,      // 0-25%: Small book, minimal rotation
  growing,      // 25-75%: Growing, faster rotation
  disappearing, // 75-100%: Fading out
}

class ScrollingBookRevealWidget extends StatefulWidget {
  final String bookCoverUrl;
  final String bookTitle;
  final String bookAuthor;
  final double scrollProgress; // 0.0 to 1.0
  final double screenHeight;

  const ScrollingBookRevealWidget({
    super.key,
    required this.bookCoverUrl,
    required this.bookTitle,
    required this.bookAuthor,
    required this.scrollProgress,
    required this.screenHeight,
  });

  @override
  State<ScrollingBookRevealWidget> createState() => _ScrollingBookRevealWidgetState();
}

class _ScrollingBookRevealWidgetState extends State<ScrollingBookRevealWidget>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  BookRevealState _currentState = BookRevealState.initial;

  @override
  void initState() {
    super.initState();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ScrollingBookRevealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    final newState = _getCurrentState();

    if (newState != _currentState) {
      _currentState = newState;

      switch (_currentState) {
        case BookRevealState.disappearing:
          _startSparkleAnimation();
          break;
        default:
          break;
      }
    }
  }

  BookRevealState _getCurrentState() {
    if (widget.scrollProgress < 0.25) return BookRevealState.initial;
    if (widget.scrollProgress < 0.75) return BookRevealState.growing;
    return BookRevealState.disappearing;
  }

  void _startSparkleAnimation() {
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate transformations based on scroll progress
    final scale = _calculateScale();
    final rotation = _calculateRotation();
    final opacity = _calculateOpacity();
    final yOffset = _calculateYOffset();

    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: _buildBook(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBook() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 60,
            offset: const Offset(0, 30),
            spreadRadius: 15,
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 80,
            offset: const Offset(0, 5),
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.bookCoverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.book, size: 40, color: Colors.white70),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            // Sparkle effects during disappearing
            if (_currentState == BookRevealState.disappearing)
              _buildSparkleEffects(),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkleEffects() {
    return CustomPaint(
      painter: SparklePainter(_sparkleAnimation.value),
      child: Container(),
    );
  }

  // Animation calculations based on scroll progress
  double _calculateScale() {
    if (widget.scrollProgress < 0.25) return 1.0;
    if (widget.scrollProgress < 0.75) {
      // Grow from 1.0 to 2.5 over longer period for smoother effect
      final progress = (widget.scrollProgress - 0.25) / 0.5;
      return 1.0 + progress * 1.5;
    }

    // Fade out scale from 2.5 to 1.8
    final progress = (widget.scrollProgress - 0.75) / 0.25;
    return 2.5 - progress * 0.7;
  }

  double _calculateRotation() {
    if (widget.scrollProgress < 0.25) return 0.0;

    // Rotation gets faster as we progress
    final progress = (widget.scrollProgress - 0.25) / 0.75;
    return progress * progress * 6.28; // Quadratic acceleration, full rotation
  }

  double _calculateOpacity() {
    if (widget.scrollProgress < 0.75) return 1.0;

    // Fade out from 0.75 to 1.0
    final progress = (widget.scrollProgress - 0.75) / 0.25;
    return 1.0 - progress;
  }

  double _calculateYOffset() {
    // Slight upward movement during opening
    if (widget.scrollProgress < 0.5) return 0.0;

    final progress = (widget.scrollProgress - 0.5) / 0.5;
    return -progress * 80; // Move up 80 pixels
  }
}

class SparklePainter extends CustomPainter {
  final double animationValue;

  SparklePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.4),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkle = sparkles[i];
      final sparkleProgress = (animationValue + i * 0.2) % 1.0;
      final sparkleSize = 2.0 + sparkleProgress * 4.0;
      final sparkleOpacity = 1.0 - sparkleProgress;

      paint.color = Colors.white.withValues(alpha: sparkleOpacity * 0.8);
      canvas.drawCircle(sparkle, sparkleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}