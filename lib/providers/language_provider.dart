import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lang/app_localizations.dart';
import '../models/language_model.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = LanguageConstants.defaultLanguageCode;
  late AppLocalizations _localizations;
  bool _isFirstLaunch = false;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  LanguageProvider() {
    _localizations = AppLocalizations(_currentLanguage);
  }

  // Getters
  String get currentLanguage => _currentLanguage;
  AppLocalizations get l10n => _localizations;
  Locale get currentLocale => LanguageConstants.getLanguageByCode(_currentLanguage).locale;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isInitialized => _isInitialized;

  // Initialize the provider with persistence
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Check if this is first launch
      _isFirstLaunch = !(_prefs?.getBool(LanguageConstants.firstLaunchCompleteKey) ?? false);
      
      // Load saved language if not first launch
      if (!_isFirstLaunch) {
        final savedLanguage = _prefs?.getString(LanguageConstants.selectedLanguageKey);
        if (savedLanguage != null) {
          _currentLanguage = savedLanguage;
          _localizations = AppLocalizations(_currentLanguage);
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If initialization fails, continue with default language
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Set language with persistence
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _localizations = AppLocalizations(languageCode);
      
      // Save to preferences
      try {
        await _prefs?.setString(LanguageConstants.selectedLanguageKey, languageCode);
      } catch (e) {
        // Continue even if save fails
      }
      
      notifyListeners();
    }
  }

  // Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    _isFirstLaunch = false;
    try {
      await _prefs?.setBool(LanguageConstants.firstLaunchCompleteKey, true);
    } catch (e) {
      // Continue even if save fails
    }
    notifyListeners();
  }

  // Get supported languages
  List<Language> getSupportedLanguages() {
    return LanguageConstants.supportedLanguages;
  }

  // Get language by code
  Language getLanguageByCode(String code) {
    return LanguageConstants.getLanguageByCode(code);
  }

  // Get current language object
  Language get currentLanguageObject => getLanguageByCode(_currentLanguage);
}