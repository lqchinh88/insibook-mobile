import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'config/environment.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_api_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/reading_settings_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/first_time_language_screen.dart';
import 'widgets/environment_banner.dart';

void main() {
  // Initialize environment configuration
  EnvironmentConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()..initialize()),
        ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (context) => BookApiProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ReadingSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        final themeMode = themeProvider.isInitialized ? themeProvider.currentThemeMode : ThemeMode.system;
        final brightness = themeMode == ThemeMode.dark
            ? Brightness.dark
            : themeMode == ThemeMode.light
                ? Brightness.light
                : MediaQuery.platformBrightnessOf(context);

        return FTheme(
          data: brightness == Brightness.dark
              ? redDark
              : redLight,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: languageProvider.l10n['app_title'],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AppInitializer(),
          ),
        );
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        // Show loading while initializing
        if (!languageProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show first-time language selection if needed
        if (languageProvider.isFirstLaunch) {
          return const FirstTimeLanguageScreen();
        }

        // Show main app
        return const MainNavigationScreen();
      },
    );
  }
}
