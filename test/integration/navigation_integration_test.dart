import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/main.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/screens/auth/login_screen.dart';
import 'package:insibook_mobile/screens/profile_screen.dart';
import 'package:insibook_mobile/screens/main_navigation_screen.dart';
import 'package:insibook_mobile/models/auth_models.dart';

void main() {
  group('Navigation Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createAppWithAuthState({User? user}) {
      final mockAuthProvider = MockAuthProvider(user: user);
      
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider), // Override AuthProvider
        ],
        child: const MyApp(),
      );
    }

    Widget createAppWithUnauthenticatedState() {
      final authProvider = MockAuthProvider(user: null);
      
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MyApp(),
      );
    }

    group('Profile Tab Widget Type Tests', () {
      testWidgets('should display LoginScreen when not authenticated', (WidgetTester tester) async {
        // Arrange - No user (not authenticated)
        await tester.pumpWidget(createAppWithAuthState());
        await tester.pump();

        // Act - Navigate to profile tab (index 2)
        final bottomNavBar = find.byType(BottomNavigationBar);
        expect(bottomNavBar, findsOneWidget);
        
        // Tap profile tab (3rd item, index 2)
        await tester.tap(find.text('Profile'));
        await tester.pump();

        // Assert - Should show LoginScreen widget type
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ProfileScreen), findsNothing);
      });

      testWidgets('should display ProfileScreen when authenticated', (WidgetTester tester) async {
        // Arrange - Authenticated user
        final testUser = User(
          id: 'test_user',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createAppWithAuthState(user: testUser));
        await tester.pump();

        // Act - Navigate to profile tab
        await tester.tap(find.text('Profile'));
        await tester.pump();

        // Assert - Should show ProfileScreen widget type
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });

      testWidgets('should switch from LoginScreen to ProfileScreen after authentication', (WidgetTester tester) async {
        // Start unauthenticated - need direct access to authProvider for later manipulation
        final authProvider = MockAuthProvider(user: null);
        
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MyApp(),
        ));
        await tester.pump();

        // Navigate to profile - should show login
        await tester.tap(find.text('Profile'));
        await tester.pump();
        expect(find.byType(LoginScreen), findsOneWidget);

        // Simulate successful authentication
        final testUser = User(
          id: 'new_user',
          email: 'new@example.com',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        authProvider.setUser(testUser); // Update auth state
        await tester.pump(); // Rebuild UI

        // Should now show profile screen
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });
    });
  });
}

// Mock AuthProvider that we can control
class MockAuthProvider extends AuthProvider {
  User? _user;

  MockAuthProvider({User? user}) : _user = user;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  bool get isInitialized => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  // Helper method for testing
  void setUser(User? user) {
    _user = user;
    notifyListeners(); // Trigger UI rebuild
  }
}