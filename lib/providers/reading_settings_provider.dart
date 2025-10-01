import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReadingFontSize {
  small(14, 'Small'),
  medium(16, 'Medium'),
  large(18, 'Large'),
  extraLarge(20, 'Extra Large'),
  extraExtraLarge(22, 'Extra Extra Large');

  const ReadingFontSize(this.value, this.label);

  final double value;
  final String label;

  static ReadingFontSize fromValue(double? value) {
    switch (value) {
      case 14:
        return ReadingFontSize.small;
      case 16:
        return ReadingFontSize.medium;
      case 18:
        return ReadingFontSize.large;
      case 20:
        return ReadingFontSize.extraLarge;
      case 22:
        return ReadingFontSize.extraExtraLarge;
      default:
        return ReadingFontSize.large; // Default
    }
  }
}

class ReadingSettingsProvider extends ChangeNotifier {
  ReadingFontSize _fontSize = ReadingFontSize.large;
  bool _isInitialized = false;

  ReadingFontSize get fontSize => _fontSize;
  bool get isInitialized => _isInitialized;

  ReadingSettingsProvider() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFontSize = prefs.getDouble('reading_font_size');

      if (savedFontSize != null) {
        _fontSize = ReadingFontSize.fromValue(savedFontSize);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setFontSize(ReadingFontSize fontSize) async {
    if (_fontSize == fontSize) return;

    _fontSize = fontSize;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('reading_font_size', fontSize.value);
    } catch (e) {
      // Handle storage error gracefully
    }

    notifyListeners();
  }

  double get fontSizeMultiplier {
    switch (_fontSize) {
      case ReadingFontSize.small:
        return 14.0 / 18.0; // 0.78
      case ReadingFontSize.medium:
        return 16.0 / 18.0; // 0.89
      case ReadingFontSize.large:
        return 18.0 / 18.0; // 1.0 (base)
      case ReadingFontSize.extraLarge:
        return 20.0 / 18.0; // 1.11
      case ReadingFontSize.extraExtraLarge:
        return 22.0 / 18.0; // 1.22
    }
  }

  TextStyle applyFontSize(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize != null
          ? baseStyle.fontSize! * fontSizeMultiplier
          : null,
    );
  }
}