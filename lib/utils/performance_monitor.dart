import 'package:flutter/scheduler.dart';
import 'dart:developer' as developer;

/// Performance monitoring utility for scroll animations
/// Tracks frame rates, animation performance, and provides warnings
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<int> _frameTimes = [];
  int _droppedFrames = 0;
  int _totalFrames = 0;
  bool _isMonitoring = false;

  /// Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _resetStats();
    SchedulerBinding.instance.addTimingsCallback(_onTimingsCallback);
    developer.log('Performance monitoring started', name: 'PerformanceMonitor');
  }

  /// Stop monitoring performance
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimingsCallback);

    final stats = getPerformanceStats();
    developer.log('Performance monitoring stopped: $stats', name: 'PerformanceMonitor');
  }

  /// Reset performance statistics
  void _resetStats() {
    _frameTimes.clear();
    _droppedFrames = 0;
    _totalFrames = 0;
  }

  /// Callback for frame timing updates
  void _onTimingsCallback(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    for (final timing in timings) {
      _totalFrames++;

      // Check if frame was dropped (took longer than 16.67ms for 60fps)
      // Use totalSpan instead of deprecated durationInMilliseconds
      final frameTimeInMs = timing.totalSpan.inMilliseconds;
      _frameTimes.add(frameTimeInMs);

      if (frameTimeInMs > 16) {
        _droppedFrames++;
      }

      // Keep only last 100 frame times for rolling average
      if (_frameTimes.length > 100) {
        _frameTimes.removeAt(0);
      }
    }
  }

  /// Get current performance statistics
  PerformanceStats getPerformanceStats() {
    if (_frameTimes.isEmpty) {
      return const PerformanceStats(
        averageFrameTime: 0.0,
        droppedFrames: 0,
        totalFrames: 0,
        dropRate: 0.0,
        estimatedFps: 0.0,
      );
    }

    final averageFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final dropRate = _totalFrames > 0 ? _droppedFrames / _totalFrames : 0.0;
    final estimatedFps = averageFrameTime > 0 ? 1000.0 / averageFrameTime : 0.0;

    return PerformanceStats(
      averageFrameTime: averageFrameTime,
      droppedFrames: _droppedFrames,
      totalFrames: _totalFrames,
      dropRate: dropRate,
      estimatedFps: estimatedFps,
    );
  }

  /// Check if performance is poor and should warn user
  bool shouldShowPerformanceWarning() {
    final stats = getPerformanceStats();
    return stats.dropRate > 0.15 || stats.estimatedFps < 45; // 15% drop rate or less than 45fps
  }

  /// Get performance recommendation based on current stats
  PerformanceRecommendation getPerformanceRecommendation() {
    final stats = getPerformanceStats();

    if (stats.estimatedFps < 30) {
      return PerformanceRecommendation.poor;
    } else if (stats.estimatedFps < 45 || stats.dropRate > 0.15) {
      return PerformanceRecommendation.moderate;
    } else if (stats.dropRate > 0.05) {
      return PerformanceRecommendation.good;
    } else {
      return PerformanceRecommendation.excellent;
    }
  }
}

/// Performance statistics data class
class PerformanceStats {
  final double averageFrameTime;
  final int droppedFrames;
  final int totalFrames;
  final double dropRate;
  final double estimatedFps;

  const PerformanceStats({
    required this.averageFrameTime,
    required this.droppedFrames,
    required this.totalFrames,
    required this.dropRate,
    required this.estimatedFps,
  });

  @override
  String toString() {
    return 'PerformanceStats(fps: ${estimatedFps.toStringAsFixed(1)}, '
           'dropRate: ${(dropRate * 100).toStringAsFixed(1)}%, '
           'droppedFrames: $droppedFrames/$totalFrames)';
  }
}

/// Performance recommendation levels
enum PerformanceRecommendation {
  excellent,  // >55fps, <5% drops
  good,       // 45-55fps, <15% drops
  moderate,   // 30-45fps, <20% drops
  poor,       // <30fps or >20% drops
}