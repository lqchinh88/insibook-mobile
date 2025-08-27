// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:insibook_mobile/main.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';
import 'package:insibook_mobile/providers/book_api_provider.dart';

void main() {
  testWidgets('InsiBook app smoke test', (WidgetTester tester) async {
    // Setup SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    
    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => BookApiProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for initial frame only (avoid network requests)
    await tester.pump();

    // Verify that the basic app structure is present
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify the app has navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
