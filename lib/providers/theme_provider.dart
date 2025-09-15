import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  bool _isInitialized = false;

  ThemeModeOption get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return false;
      case ThemeModeOption.dark:
        return true;
      case ThemeModeOption.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');

      if (savedTheme != null) {
        _themeMode = ThemeModeOption.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => ThemeModeOption.system,
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeModeOption themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', themeMode.name);
    } catch (e) {
      // Handle storage error gracefully
    }

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setThemeMode(ThemeModeOption.light);
    } else {
      await setThemeMode(ThemeModeOption.dark);
    }
  }
}