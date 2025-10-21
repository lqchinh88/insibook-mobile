import '../constants/scroll_animation_constants.dart';

/// Cached animation calculator to optimize scroll animation performance
/// Prevents repeated mathematical calculations during scroll updates
class AnimationCalculator {
  static final Map<String, AnimationValues> _cache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;

  /// Get cached animation values or calculate and cache new ones
  static AnimationValues getAnimationValues(double scrollProgress) {
    final key = scrollProgress.toStringAsFixed(3);

    if (_cache.containsKey(key)) {
      _cacheHits++;
      return _cache[key]!;
    }

    _cacheMisses++;
    final values = _calculateAnimationValues(scrollProgress);

    // Limit cache size to prevent memory issues
    if (_cache.length >= ScrollAnimationConstants.maxCacheSize) {
      _cache.clear();
    }

    _cache[key] = values;
    return values;
  }

  /// Calculate all animation values for a given scroll progress
  static AnimationValues _calculateAnimationValues(double scrollProgress) {
    return AnimationValues(
      scale: _calculateScale(scrollProgress),
      rotation: _calculateRotation(scrollProgress),
      opacity: _calculateOpacity(scrollProgress),
      yOffset: _calculateYOffset(scrollProgress),
      currentState: _getCurrentState(scrollProgress),
    );
  }

  /// Determine current animation state based on scroll progress
  static BookRevealState _getCurrentState(double scrollProgress) {
    if (scrollProgress < ScrollAnimationConstants.initialRevealThreshold) {
      return BookRevealState.initial;
    }
    if (scrollProgress < ScrollAnimationConstants.growingRevealThreshold) {
      return BookRevealState.growing;
    }
    return BookRevealState.disappearing;
  }

  /// Calculate scale based on scroll progress
  static double _calculateScale(double scrollProgress) {
    if (scrollProgress < ScrollAnimationConstants.initialRevealThreshold) {
      return ScrollAnimationConstants.initialScale;
    }

    if (scrollProgress < ScrollAnimationConstants.growingRevealThreshold) {
      // Grow from initial to max scale over growing period
      final progress = (scrollProgress - ScrollAnimationConstants.initialRevealThreshold) /
                      (ScrollAnimationConstants.growingRevealThreshold - ScrollAnimationConstants.initialRevealThreshold);
      return ScrollAnimationConstants.initialScale + progress *
             (ScrollAnimationConstants.maxScale - ScrollAnimationConstants.initialScale);
    }

    // Fade out scale from max to fadeOut scale
    final progress = (scrollProgress - ScrollAnimationConstants.growingRevealThreshold) /
                    (1.0 - ScrollAnimationConstants.growingRevealThreshold);
    return ScrollAnimationConstants.maxScale - progress *
           (ScrollAnimationConstants.maxScale - ScrollAnimationConstants.fadeOutScale);
  }

  /// Calculate rotation based on scroll progress
  static double _calculateRotation(double scrollProgress) {
    if (scrollProgress < ScrollAnimationConstants.initialRevealThreshold) {
      return 0.0;
    }

    // Quadratic acceleration for more natural rotation
    final progress = (scrollProgress - ScrollAnimationConstants.initialRevealThreshold) /
                    (1.0 - ScrollAnimationConstants.initialRevealThreshold);
    return progress * progress * ScrollAnimationConstants.fullRotation;
  }

  /// Calculate opacity based on scroll progress
  static double _calculateOpacity(double scrollProgress) {
    if (scrollProgress < ScrollAnimationConstants.growingRevealThreshold) {
      return 1.0;
    }

    // Fade out from growing threshold to end
    final progress = (scrollProgress - ScrollAnimationConstants.growingRevealThreshold) /
                    (1.0 - ScrollAnimationConstants.growingRevealThreshold);
    return 1.0 - progress;
  }

  /// Calculate Y offset based on scroll progress
  static double _calculateYOffset(double scrollProgress) {
    // Slight upward movement during second half
    if (scrollProgress < 0.5) {
      return 0.0;
    }

    final progress = (scrollProgress - 0.5) / 0.5;
    return progress * ScrollAnimationConstants.maxUpwardOffset;
  }

  /// Get cache performance statistics
  static CacheStats getCacheStats() {
    final total = _cacheHits + _cacheMisses;
    final hitRate = total > 0 ? _cacheHits / total : 0.0;

    return CacheStats(
      cacheSize: _cache.length,
      hits: _cacheHits,
      misses: _cacheMisses,
      hitRate: hitRate,
    );
  }

  /// Clear cache (useful for testing or memory management)
  static void clearCache() {
    _cache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }
}

/// Data class containing all animation values for a given scroll progress
class AnimationValues {
  final double scale;
  final double rotation;
  final double opacity;
  final double yOffset;
  final BookRevealState currentState;

  const AnimationValues({
    required this.scale,
    required this.rotation,
    required this.opacity,
    required this.yOffset,
    required this.currentState,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimationValues &&
          runtimeType == other.runtimeType &&
          scale == other.scale &&
          rotation == other.rotation &&
          opacity == other.opacity &&
          yOffset == other.yOffset &&
          currentState == other.currentState;

  @override
  int get hashCode =>
      scale.hashCode ^
      rotation.hashCode ^
      opacity.hashCode ^
      yOffset.hashCode ^
      currentState.hashCode;

  @override
  String toString() {
    return 'AnimationValues(scale: $scale, rotation: $rotation, opacity: $opacity, yOffset: $yOffset, currentState: $currentState)';
  }
}

/// Cache performance statistics
class CacheStats {
  final int cacheSize;
  final int hits;
  final int misses;
  final double hitRate;

  const CacheStats({
    required this.cacheSize,
    required this.hits,
    required this.misses,
    required this.hitRate,
  });

  @override
  String toString() {
    return 'CacheStats(size: $cacheSize, hits: $hits, misses: $misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Animation states for book reveal
enum BookRevealState {
  initial,      // 0-25%: Small book, minimal rotation
  growing,      // 25-75%: Growing, faster rotation
  disappearing, // 75-100%: Fading out
}