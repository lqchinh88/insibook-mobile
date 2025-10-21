import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/scroll_animation_constants.dart';
import '../utils/animation_calculator.dart';
import '../widgets/optimized_sparkle_widget.dart';

/// Optimized ScrollingBookRevealWidget with performance improvements:
/// - Single combined transform instead of nested transforms
/// - Cached animation calculations
/// - RepaintBoundary for better performance
/// - Optimized sparkle effects
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

class _ScrollingBookRevealWidgetState extends State<ScrollingBookRevealWidget> {
  BookRevealState? _currentState;
  AnimationValues? _cachedValues;

  @override
  void didUpdateWidget(ScrollingBookRevealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    final values = AnimationCalculator.getAnimationValues(widget.scrollProgress);

    if (_currentState != values.currentState) {
      _currentState = values.currentState;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get cached animation values to prevent repeated calculations
    final animationValues = AnimationCalculator.getAnimationValues(widget.scrollProgress);
    _cachedValues = animationValues;

    
    // Apply transformations with optimized nesting for better performance
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(0.0, animationValues.yOffset),
        child: Transform.scale(
          scale: animationValues.scale,
          child: Transform.rotate(
            angle: animationValues.rotation,
            child: Opacity(
              opacity: animationValues.opacity,
              child: _buildBook(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBook() {
    return RepaintBoundary(
      child: Container(
        width: ScrollAnimationConstants.bookCoverWidth,
        height: ScrollAnimationConstants.bookCoverHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScrollAnimationConstants.bookCoverRadius),
          boxShadow: [
            ...ScrollAnimationConstants.bookShadows,
            // Add primary-themed shadow when in disappearing state
            if (_cachedValues?.currentState == BookRevealState.disappearing)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 80,
                offset: const Offset(0, 5),
                spreadRadius: 20,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ScrollAnimationConstants.bookCoverRadius),
          child: Stack(
            children: [
              // Book cover image
              _buildBookCoverImage(),

              // Sparkle effects during disappearing state
              if (_cachedValues?.currentState == BookRevealState.disappearing)
                OptimizedSparkleWidget(
                  animationProgress: widget.scrollProgress,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCoverImage() {
    return CachedNetworkImage(
      imageUrl: widget.bookCoverUrl,
      fit: BoxFit.cover,
      memCacheWidth: (ScrollAnimationConstants.bookCoverWidth * 2).round(),
      memCacheHeight: (ScrollAnimationConstants.bookCoverHeight * 2).round(),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
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
        child: Icon(
          Icons.book,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}