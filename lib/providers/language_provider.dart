import 'package:flutter/material.dart';
import '../lang/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  late AppLocalizations _localizations;

  LanguageProvider() {
    _localizations = AppLocalizations(_currentLanguage);
  }

  String get currentLanguage => _currentLanguage;
  AppLocalizations get l10n => _localizations;

  void setLanguage(String language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      _localizations = AppLocalizations(language);
      notifyListeners();
    }
  }
}