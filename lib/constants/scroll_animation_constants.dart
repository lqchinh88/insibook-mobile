import 'package:flutter/material.dart';

/// Centralized constants for scroll spinning animations
/// Replaces magic numbers with configurable, well-documented values
class ScrollAnimationConstants {
  // Private constructor to prevent instantiation
  ScrollAnimationConstants._();

  // Book reveal state thresholds (0.0 to 1.0)
  static const double initialRevealThreshold = 0.25;
  static const double growingRevealThreshold = 0.75;

  // Scale animation values
  static const double initialScale = 1.0;
  static const double maxScale = 2.5;
  static const double fadeOutScale = 1.8;

  // Rotation animation values
  static const double fullRotation = 6.283185307179586; // 2π radians

  // Offset animation values
  static const double maxUpwardOffset = -80.0;
  static const double earlyAnimationStart = -50.0;  // Reduced early start trigger
  static const double extendedAnimationEnd = 50.0;

  // Scroll calculation constants
  static const double bookDetailsHeight = 500.0; // Updated for actual content height
  static const double bottomPadding = 100.0;
  static const double sectionSpacingReduction = 200.0; // Reduced spacing between books

  // Sparkle animation constants
  static const Duration sparkleDuration = Duration(milliseconds: 2000);
  static const int sparkleCount = 5;
  static const double minSparkleSize = 2.0;
  static const double maxSparkleSize = 6.0;
  static const double sparkleOpacity = 0.8;

  // Performance optimization constants
  static const int maxCacheSize = 100;
  static const Duration performanceUpdateInterval = Duration(milliseconds: 100);

  // Book cover dimensions
  static const double bookCoverWidth = 200.0;
  static const double bookCoverHeight = 300.0;
  static const double bookCoverRadius = 12.0;

  // Shadow and visual effects
  static final List<BoxShadow> bookShadows = [
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.4),
      blurRadius: 30,
      offset: const Offset(0, 15),
      spreadRadius: 8,
    ),
    BoxShadow(
      color: const Color.fromRGBO(0, 0, 0, 0.3),
      blurRadius: 60,
      offset: const Offset(0, 30),
      spreadRadius: 15,
    ),
  ];

  // Sparkle positions relative to book cover (normalized 0.0 to 1.0)
  static final List<Offset> sparklePositions = [
    const Offset(0.2, 0.3),
    const Offset(0.8, 0.2),
    const Offset(0.7, 0.7),
    const Offset(0.3, 0.8),
    const Offset(0.5, 0.4),
  ];
}