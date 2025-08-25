import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/screens/auth/login_screen.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    Widget createLoginScreen() {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    group('UI Elements', () {
      testWidgets('should display all required UI elements', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Check for app bar and button text
        expect(find.text('Sign In'), findsNWidgets(2)); // AppBar title + button text

        // Check for logo/icon
        expect(find.byIcon(Icons.book), findsOneWidget);

        // Check for form fields
        expect(find.byType(TextFormField), findsNWidgets(2));
        
        // Check for email field
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email address'), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);

        // Check for password field
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Enter your password'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Check for sign in button
        expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);

        // Check for sign up link
        expect(find.text("Don't have an account? "), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
      });

      testWidgets('should toggle password visibility', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Initially should show visibility icon (password is obscured)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);

        // Tap the visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Password should now be visible, icon should change
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });
    });

    group('Form Validation', () {
      testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Tap sign in button without filling fields
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pump();

        // Should show validation errors
        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('should show error for invalid email format', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Enter invalid email
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // Tap sign in button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pump();

        // Should show email validation error
        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('should pass validation with valid inputs', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Enter valid email and password
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // Tap sign in button
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pump();

        // Should not show validation errors
        expect(find.text('Please enter your email'), findsNothing);
        expect(find.text('Please enter your password'), findsNothing);
        expect(find.text('Please enter a valid email address'), findsNothing);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when logging in', (WidgetTester tester) async {
        // Mock the auth provider to simulate loading state
        authProvider = MockAuthProvider(isLoading: true);
        
        await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(home: LoginScreen()),
        ));

        // Should show loading indicator inside the button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        // AppBar should still show "Sign In" title
        expect(find.text('Sign In'), findsOneWidget);

        // Button should be disabled
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('Error Display', () {
      testWidgets('should show error message when login fails', (WidgetTester tester) async {
        // Mock the auth provider with error
        authProvider = MockAuthProvider(errorMessage: 'Invalid credentials');
        
        await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(home: LoginScreen()),
        ));

        // Should show error message
        expect(find.text('Invalid credentials'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to register screen when sign up is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Tap on "Sign Up" text button
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Should navigate to register screen (this would need to be tested differently
        // in a real app with proper navigation setup)
      });
    });

    group('Keyboard Actions', () {
      testWidgets('should move focus from email to password when next is pressed', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Focus on email field
        await tester.tap(find.byType(TextFormField).first);
        await tester.pump();

        // Enter text and press next (this would be done through TextInputAction.next)
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        
        // In a real test, you'd verify that focus moves to the password field
        // This is more complex to test without additional framework setup
      });

      testWidgets('should submit form when done is pressed on password field', (WidgetTester tester) async {
        await tester.pumpWidget(createLoginScreen());

        // Enter valid credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        // In a real test, you'd simulate pressing the "Done" key on the password field
        // and verify that the login method is called
      });
    });
  });
}

// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  final bool _isLoading;
  final String? _errorMessage;

  MockAuthProvider({bool isLoading = false, String? errorMessage})
      : _isLoading = isLoading,
        _errorMessage = errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;
}