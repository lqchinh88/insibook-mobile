import 'dart:collection';
import '../models/book_models.dart';

/// Session-based cache for BookWithContent objects with language awareness
class BookContentCache {
  static final Map<String, BookWithContent> _cache = {};
  static final LinkedHashMap<String, DateTime> _accessTimes = LinkedHashMap();
  static const int _maxCacheSize = 50;

  /// Generate cache key combining book ID and language
  static String _getCacheKey(String bookId, String language) => '${bookId}_$language';

  /// Get cached BookWithContent for specific book and language
  static BookWithContent? get(String bookId, String language) {
    final key = _getCacheKey(bookId, language);
    if (_cache.containsKey(key)) {
      _accessTimes[key] = DateTime.now(); // Update access time for LRU
      return _cache[key];
    }
    return null;
  }

  /// Cache BookWithContent for specific book and language
  static void set(String bookId, String language, BookWithContent bookContent) {
    final key = _getCacheKey(bookId, language);
    
    // If cache is full, evict least recently used item
    if (_cache.length >= _maxCacheSize && !_cache.containsKey(key)) {
      _evictLRU();
    }
    
    _cache[key] = bookContent;
    _accessTimes[key] = DateTime.now();
  }

  /// Check if BookWithContent is cached for specific book and language
  static bool has(String bookId, String language) {
    final key = _getCacheKey(bookId, language);
    return _cache.containsKey(key);
  }

  /// Check if cached book has insights for specific book and language
  static bool hasInsights(String bookId, String language) {
    final content = get(bookId, language);
    return content?.hasInsights ?? false;
  }

  /// Get all cached book IDs (without language suffix)
  static List<String> getCachedBookIds() {
    return _cache.keys
        .map((key) => key.split('_').first)
        .toSet()
        .toList();
  }

  /// Get all languages cached for a specific book ID
  static List<String> getCachedLanguagesForBook(String bookId) {
    return _cache.keys
        .where((key) => key.startsWith('${bookId}_'))
        .map((key) => key.split('_').last)
        .toList();
  }

  /// Clear all cached content
  static void clear() {
    _cache.clear();
    _accessTimes.clear();
  }

  /// Remove cached content for specific book and language
  static void remove(String bookId, String language) {
    final key = _getCacheKey(bookId, language);
    _cache.remove(key);
    _accessTimes.remove(key);
  }

  /// Remove all cached content for a specific book (all languages)
  static void removeBook(String bookId) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith('${bookId}_'))
        .toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessTimes.remove(key);
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': _maxCacheSize,
      'keys': _cache.keys.toList(),
      'usage': (_cache.length / _maxCacheSize * 100).toStringAsFixed(1),
    };
  }

  /// Evict least recently used item
  static void _evictLRU() {
    if (_accessTimes.isEmpty) return;
    
    // Find the key with the oldest access time
    String oldestKey = _accessTimes.keys.first;
    DateTime oldestTime = _accessTimes[oldestKey]!;
    
    for (final entry in _accessTimes.entries) {
      if (entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    _cache.remove(oldestKey);
    _accessTimes.remove(oldestKey);
  }

  /// Force evict LRU items to free up space (for testing or memory pressure)
  static void evictLRU({int count = 1}) {
    for (int i = 0; i < count && _cache.isNotEmpty; i++) {
      _evictLRU();
    }
  }
}