import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/environment.dart';
import 'config/app_config.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_api_provider.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: languageProvider.l10n['app_title'] ?? AppConfig.appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),
          home: const EnvironmentBanner(
            child: AppInitializer(),
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
