import 'package:flutter/material.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

class LanguageConstants {
  LanguageConstants._();

  // Supported languages
  static const Language english = Language(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
    locale: Locale('en'),
  );

  static const Language vietnamese = Language(
    code: 'vi',
    name: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    flag: '🇻🇳',
    locale: Locale('vi'),
  );

  static const List<Language> supportedLanguages = [
    english,
    vietnamese,
  ];

  // Storage keys for SharedPreferences
  static const String selectedLanguageKey = 'selected_language';
  static const String firstLaunchCompleteKey = 'first_launch_complete';

  // Default language
  static const String defaultLanguageCode = 'en';

  // Helper method to get language by code
  static Language getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }
}