import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/main.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';
import 'package:insibook_mobile/providers/language_provider.dart';
import 'package:insibook_mobile/providers/book_api_provider.dart';
import 'package:insibook_mobile/screens/auth/login_screen.dart';
import 'package:insibook_mobile/screens/auth/register_screen.dart';
import 'package:insibook_mobile/screens/profile_screen.dart';
import 'package:insibook_mobile/screens/library_screen.dart';
import 'package:insibook_mobile/screens/login_required_screen.dart';
import 'package:insibook_mobile/models/auth_models.dart';
import 'package:insibook_mobile/models/book_models.dart';
import 'package:insibook_mobile/services/api_service.dart';
import 'package:insibook_mobile/services/book_api_service.dart';
import 'package:insibook_mobile/utils/result.dart';

import 'navigation_integration_test.mocks.dart';

@GenerateMocks([http.Client, BookApiService])
void main() {
  group('Navigation Integration Tests', () {
    late MockBookApiService mockBookApiService;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'first_launch_complete': true, // Skip first time language screen
        'selected_language': 'en',
      });
      mockBookApiService = MockBookApiService();
      
      // Provide dummy values for Result types
      provideDummy<Result<InternalBookSearchResponse, ApiError>>(
        Success(InternalBookSearchResponse(books: [], total: 0, count: 0, offset: 0)),
      );
      provideDummy<Result<BookSearchResponse, ApiError>>(
        Success(BookSearchResponse(items: [], totalItems: 0)),
      );
      provideDummy<Result<List<BookCategory>, ApiError>>(
        Success(<BookCategory>[]),
      );

      // Stub BookApiService methods that are called during screen initialization
      when(mockBookApiService.getLatestBooks(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => Success(InternalBookSearchResponse(
        books: [],
        total: 0,
        count: 0,
        offset: 0,
      )));

      when(mockBookApiService.getAllCategories()).thenAnswer((_) async => Success(<BookCategory>[]));
    });

    Widget createAppWithAuthState({User? user}) {
      final mockAuthProvider = MockAuthProvider(user: user);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>(
            create: (context) => LanguageProvider()..initialize(),
          ),
          ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuthProvider,
          ), // Override AuthProvider
          ChangeNotifierProvider<BookApiProvider>(
            create: (context) => BookApiProvider(bookApiService: mockBookApiService),
          ),
        ],
        child: const MyApp(),
      );
    }

    group('Profile Tab Widget Type Tests', () {
      testWidgets(
        'should push LoginScreen immediately when tapping Profile while unauthenticated',
        (WidgetTester tester) async {
          // Arrange - No user (not authenticated)
          await tester.pumpWidget(createAppWithAuthState());
          await tester.pumpAndSettle(); // Wait for initialization

          // Act - Navigate to profile tab (index 2)
          final bottomNavBar = find.byType(BottomNavigationBar);
          expect(bottomNavBar, findsOneWidget);

          // Tap profile tab (3rd item, index 2)
          await tester.tap(find.text('Profile'));
          await tester.pumpAndSettle(); // Wait for navigation to complete

          // Assert - Should immediately push LoginScreen on top
          expect(find.byType(LoginScreen), findsOneWidget);
          expect(find.byType(ProfileScreen), findsNothing);
          // LoginRequiredScreen should be underneath but not visible
        },
      );

      testWidgets('should show LoginRequiredScreen when user cancels login', (
        WidgetTester tester,
      ) async {
        // Arrange - No user (not authenticated)
        await tester.pumpWidget(createAppWithAuthState());
        await tester.pump();

        // Tap profile tab to trigger LoginScreen push
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);

        // User backs out/cancels login
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Should now show LoginRequiredScreen
        expect(find.byType(LoginRequiredScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(ProfileScreen), findsNothing);

        // Should show login button for retry
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      });

      testWidgets('should display ProfileScreen when authenticated', (
        WidgetTester tester,
      ) async {
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

      testWidgets('should navigate to ProfileScreen after successful login', (
        WidgetTester tester,
      ) async {
        // Setup HTTP mock for successful login
        final mockHttpClient = MockClient();
        final originalClient = ApiService.httpClient;
        ApiService.httpClient = mockHttpClient;

        final authResponseJson = {
          'accessToken': 'test_token_123',
          'user': {
            'id': 'new_user',
            'email': 'test@example.com',
            'firstName': 'Test',
            'lastName': 'User',
            'role': 'free_user',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(authResponseJson), 200),
        );

        try {
          // Start with real AuthProvider (unauthenticated)
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => LanguageProvider()..initialize()),
                ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
                ChangeNotifierProvider(create: (context) => BookApiProvider(bookApiService: mockBookApiService)),
              ],
              child: const MyApp(),
            ),
          );
          await tester.pumpAndSettle(); // Wait for initialization

          // Navigate to profile - should immediately push LoginScreen
          await tester.tap(find.text('Profile'));
          await tester.pumpAndSettle();
          expect(find.byType(LoginScreen), findsOneWidget);

          // Fill login form
          await tester.enterText(
            find.byType(TextFormField).first,
            'test@example.com',
          );
          await tester.enterText(
            find.byType(TextFormField).at(1),
            'password123',
          );

          // Tap login button - this triggers real authentication flow
          await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
          await tester.pumpAndSettle(); // Wait for initialization // Start login process

          // Wait for HTTP call and state updates
          await tester.pumpAndSettle();

          // Should now show profile screen after real login
          expect(find.byType(ProfileScreen), findsOneWidget);
          expect(find.byType(LoginScreen), findsNothing);

          // Verify HTTP call was made with correct data
          verify(
            mockHttpClient.post(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).called(1);
        } finally {
          // Restore original HTTP client
          ApiService.httpClient = originalClient;
        }
      });

      testWidgets(
        'should navigate to ProfileScreen after successful registration',
        (WidgetTester tester) async {
          // Setup HTTP mock for successful registration
          final mockHttpClient = MockClient();
          final originalClient = ApiService.httpClient;
          ApiService.httpClient = mockHttpClient;

          final authResponseJson = {
            'accessToken': 'test_token_456',
            'user': {
              'id': 'new_user_reg',
              'email': 'newuser@example.com',
              'firstName': 'New',
              'lastName': 'User',
              'role': 'free_user',
              'isActive': true,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          };

          when(
            mockHttpClient.post(
              Uri.parse('${ApiService.baseUrl}/auth/register'),
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).thenAnswer((_) async {
            return http.Response(
              jsonEncode(authResponseJson),
              201, // Registration typically returns 201
            );
          });

          try {
            // Start with real AuthProvider (unauthenticated)
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => LanguageProvider()..initialize(),
                  ),
                  ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
                  ChangeNotifierProvider(create: (context) => BookApiProvider(bookApiService: mockBookApiService)),
                ],
                child: const MyApp(),
              ),
            );
            await tester.pumpAndSettle(); // Wait for initialization

            // Navigate to profile - should immediately push LoginScreen
            await tester.tap(find.text('Profile'));
            await tester.pumpAndSettle();
            expect(find.byType(LoginScreen), findsOneWidget);

            // Navigate to register screen by tapping Sign Up
            final signUpButton = find.widgetWithText(TextButton, 'Sign Up');
            await tester.ensureVisible(
              signUpButton,
            ); // Ensure button is visible
            await tester.tap(signUpButton);
            await tester.pumpAndSettle();
            expect(find.byType(RegisterScreen), findsOneWidget);

            // Fill registration form
            final firstNameField = find.byType(TextFormField).at(0);
            final lastNameField = find.byType(TextFormField).at(1);
            final emailField = find.byType(TextFormField).at(2);
            final passwordField = find.byType(TextFormField).at(3);
            final confirmPasswordField = find.byType(TextFormField).at(4);

            await tester.enterText(firstNameField, 'New');
            await tester.enterText(lastNameField, 'User');
            await tester.enterText(emailField, 'newuser@example.com');
            await tester.enterText(passwordField, 'password123');
            await tester.enterText(confirmPasswordField, 'password123');

            // Tap register button
            final registerButton = find.widgetWithText(
              ElevatedButton,
              'Create Account',
            );
            await tester.ensureVisible(registerButton);
            await tester.tap(registerButton, warnIfMissed: false);
            await tester.pumpAndSettle(); // Wait for initialization // Start registration process

            // Wait for HTTP call and navigation
            await tester.pumpAndSettle();

            // Should now show ProfileScreen after successful registration
            expect(find.byType(ProfileScreen), findsOneWidget);
            expect(find.byType(RegisterScreen), findsNothing);
            expect(find.byType(LoginScreen), findsNothing);

            // Verify HTTP call was made for registration
            verify(
              mockHttpClient.post(
                any,
                headers: anyNamed('headers'),
                body: anyNamed('body'),
              ),
            ).called(1);
          } finally {
            // Restore original HTTP client
            ApiService.httpClient = originalClient;
          }
        },
      );
    });

    group('Library Tab Widget Type Tests', () {
      testWidgets(
        'should push LoginScreen immediately when tapping Library while unauthenticated',
        (WidgetTester tester) async {
          // Arrange - No user (not authenticated)
          await tester.pumpWidget(createAppWithAuthState());
          await tester.pumpAndSettle(); // Wait for initialization
          
          // Act - Navigate to library tab (index 2)
          final bottomNavBar = find.byType(BottomNavigationBar);
          expect(bottomNavBar, findsOneWidget);
          
          // Tap library tab
          await tester.tap(find.text('Library'));
          await tester.pumpAndSettle(); // Wait for navigation to complete
          
          // Assert - Should immediately push LoginScreen on top
          expect(find.byType(LoginScreen), findsOneWidget);
          expect(find.byType(LibraryScreen), findsNothing);
          // LoginRequiredScreen should be underneath but not visible
        },
      );

      testWidgets('should show LibraryScreen when user cancels library login', (
        WidgetTester tester,
      ) async {
        // Arrange - No user (not authenticated)
        await tester.pumpWidget(createAppWithAuthState());
        await tester.pump();
        
        // Tap library tab to trigger LoginScreen push
        await tester.tap(find.text('Library'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
        
        // User backs out/cancels login
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // Should now show LibraryScreen (which internally shows not authenticated state)
        expect(find.byType(LibraryScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
        
        // Should show the "Sign in to view your library" message
        expect(find.text('Sign in to view your library'), findsOneWidget);
        
        // Should show Login button for retry
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      });

      testWidgets('should display LibraryScreen when authenticated', (
        WidgetTester tester,
      ) async {
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
        
        // Act - Navigate to library tab
        await tester.tap(find.text('Library'));
        await tester.pump();
        
        // Assert - Should show LibraryScreen widget type
        expect(find.byType(LibraryScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });

      testWidgets('should navigate to LibraryScreen after successful login', (
        WidgetTester tester,
      ) async {
        // Setup HTTP mock for successful login
        final mockHttpClient = MockClient();
        final originalClient = ApiService.httpClient;
        ApiService.httpClient = mockHttpClient;
        
        final authResponseJson = {
          'accessToken': 'test_token_123',
          'user': {
            'id': 'new_user',
            'email': 'test@example.com',
            'firstName': 'Test',
            'lastName': 'User',
            'role': 'free_user',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(jsonEncode(authResponseJson), 200),
        );

        try {
          // Start with real AuthProvider (unauthenticated)
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => LanguageProvider()..initialize()),
                ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
                ChangeNotifierProvider(create: (context) => BookApiProvider(bookApiService: mockBookApiService)),
              ],
              child: const MyApp(),
            ),
          );
          await tester.pumpAndSettle(); // Wait for initialization

          // Navigate to library - should immediately push LoginScreen
          await tester.tap(find.text('Library'));
          await tester.pumpAndSettle();
          expect(find.byType(LoginScreen), findsOneWidget);

          // Fill login form
          await tester.enterText(
            find.byType(TextFormField).first,
            'test@example.com',
          );
          await tester.enterText(
            find.byType(TextFormField).at(1),
            'password123',
          );

          // Tap login button - this triggers real authentication flow
          await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
          await tester.pumpAndSettle(); // Wait for initialization // Start login process

          // Wait for HTTP call and state updates
          await tester.pumpAndSettle();

          // Should now show library screen after real login
          expect(find.byType(LibraryScreen), findsOneWidget);
          expect(find.byType(LoginScreen), findsNothing);

          // Verify HTTP call was made with correct data
          verify(
            mockHttpClient.post(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).called(1);
        } finally {
          // Restore original HTTP client
          ApiService.httpClient = originalClient;
        }
      });

      testWidgets(
        'should navigate to LibraryScreen after successful registration',
        (WidgetTester tester) async {
          // Setup HTTP mock for successful registration
          final mockHttpClient = MockClient();
          final originalClient = ApiService.httpClient;
          ApiService.httpClient = mockHttpClient;
          
          final authResponseJson = {
            'accessToken': 'test_token_456',
            'user': {
              'id': 'new_user_reg',
              'email': 'newuser@example.com',
              'firstName': 'New',
              'lastName': 'User',
              'role': 'free_user',
              'isActive': true,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          };

          when(
            mockHttpClient.post(
              Uri.parse('${ApiService.baseUrl}/auth/register'),
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).thenAnswer((_) async {
            return http.Response(
              jsonEncode(authResponseJson),
              201, // Registration typically returns 201
            );
          });

          try {
            // Start with real AuthProvider (unauthenticated)
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => LanguageProvider()..initialize(),
                  ),
                  ChangeNotifierProvider(create: (context) => AuthProvider()..initialize()),
                  ChangeNotifierProvider(create: (context) => BookApiProvider(bookApiService: mockBookApiService)),
                ],
                child: const MyApp(),
              ),
            );
            await tester.pumpAndSettle(); // Wait for initialization

            // Navigate to library - should immediately push LoginScreen
            await tester.tap(find.text('Library'));
            await tester.pumpAndSettle();
            expect(find.byType(LoginScreen), findsOneWidget);

            // Navigate to register screen by tapping Sign Up
            final signUpButton = find.widgetWithText(TextButton, 'Sign Up');
            await tester.ensureVisible(signUpButton); // Ensure button is visible
            await tester.tap(signUpButton);
            await tester.pumpAndSettle();
            expect(find.byType(RegisterScreen), findsOneWidget);

            // Fill registration form
            final firstNameField = find.byType(TextFormField).at(0);
            final lastNameField = find.byType(TextFormField).at(1);
            final emailField = find.byType(TextFormField).at(2);
            final passwordField = find.byType(TextFormField).at(3);
            final confirmPasswordField = find.byType(TextFormField).at(4);

            await tester.enterText(firstNameField, 'New');
            await tester.enterText(lastNameField, 'User');
            await tester.enterText(emailField, 'newuser@example.com');
            await tester.enterText(passwordField, 'password123');
            await tester.enterText(confirmPasswordField, 'password123');

            // Tap register button
            final registerButton = find.widgetWithText(
              ElevatedButton,
              'Create Account',
            );
            await tester.ensureVisible(registerButton);
            await tester.tap(registerButton, warnIfMissed: false);
            await tester.pumpAndSettle(); // Wait for initialization // Start registration process

            // Wait for HTTP call and navigation
            await tester.pumpAndSettle();

            // Should now show LibraryScreen after successful registration
            expect(find.byType(LibraryScreen), findsOneWidget);
            expect(find.byType(RegisterScreen), findsNothing);
            expect(find.byType(LoginScreen), findsNothing);

            // Verify HTTP call was made for registration
            verify(
              mockHttpClient.post(
                any,
                headers: anyNamed('headers'),
                body: anyNamed('body'),
              ),
            ).called(1);
          } finally {
            // Restore original HTTP client
            ApiService.httpClient = originalClient;
          }
        },
      );
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
