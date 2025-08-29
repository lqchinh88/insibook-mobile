import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/models/language_model.dart';

void main() {
  group('Language Switcher Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('Language Model Tests', () {
      test('should contain English and Vietnamese languages', () {
        expect(LanguageConstants.supportedLanguages.length, equals(2));
        
        final english = LanguageConstants.supportedLanguages
            .firstWhere((lang) => lang.code == 'en');
        expect(english.name, equals('English'));
        expect(english.nativeName, equals('English'));
        expect(english.flag, equals('🇺🇸'));
        expect(english.locale, equals(const Locale('en')));

        final vietnamese = LanguageConstants.supportedLanguages
            .firstWhere((lang) => lang.code == 'vi');
        expect(vietnamese.name, equals('Vietnamese'));
        expect(vietnamese.nativeName, equals('Tiếng Việt'));
        expect(vietnamese.flag, equals('🇻🇳'));
        expect(vietnamese.locale, equals(const Locale('vi')));
      });

      test('should find language by code', () {
        final english = LanguageConstants.getLanguageByCode('en');
        expect(english.code, equals('en'));

        final vietnamese = LanguageConstants.getLanguageByCode('vi');
        expect(vietnamese.code, equals('vi'));

        // Should return English for unknown code
        final unknown = LanguageConstants.getLanguageByCode('unknown');
        expect(unknown.code, equals('en'));
      });
    });

    group('LanguageProvider Tests', () {
      test('should initialize with default language', () async {
        final provider = LanguageProvider();
        await provider.initialize();
        
        expect(provider.isInitialized, isTrue);
        expect(provider.currentLanguage, equals('en'));
        expect(provider.isFirstLaunch, isTrue);
      });

      test('should detect first launch correctly', () async {
        final provider = LanguageProvider();
        await provider.initialize();
        
        expect(provider.isFirstLaunch, isTrue);
        
        await provider.markFirstLaunchComplete();
        expect(provider.isFirstLaunch, isFalse);
      });

      test('should change language and persist preference', () async {
        final provider = LanguageProvider();
        await provider.initialize();
        
        expect(provider.currentLanguage, equals('en'));
        
        await provider.setLanguage('vi');
        expect(provider.currentLanguage, equals('vi'));
        
        // Mark first launch complete to simulate persistence
        await provider.markFirstLaunchComplete();
        
        // Create new provider instance to test persistence
        final newProvider = LanguageProvider();
        await newProvider.initialize();
        expect(newProvider.currentLanguage, equals('vi'));
        expect(newProvider.isFirstLaunch, isFalse);
      });

      test('should provide correct language object', () async {
        final provider = LanguageProvider();
        await provider.initialize();
        
        expect(provider.currentLanguageObject.code, equals('en'));
        
        await provider.setLanguage('vi');
        expect(provider.currentLanguageObject.code, equals('vi'));
        expect(provider.currentLanguageObject.nativeName, equals('Tiếng Việt'));
      });

      test('should return supported languages', () async {
        final provider = LanguageProvider();
        await provider.initialize();
        
        final languages = provider.getSupportedLanguages();
        expect(languages.length, equals(2));
        expect(languages.any((lang) => lang.code == 'en'), isTrue);
        expect(languages.any((lang) => lang.code == 'vi'), isTrue);
      });
    });
  });
}