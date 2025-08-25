import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/models/auth_models.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';
import 'package:insibook_mobile/services/api_service.dart';
import 'package:insibook_mobile/services/auth_service.dart';

import 'auth_flow_integration_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('Authentication Flow Integration Tests', () {
    late MockClient mockHttpClient;
    late AuthProvider authProvider;
    late http.Client originalClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockHttpClient = MockClient();
      authProvider = AuthProvider();
      
      // Store original client and inject mock
      originalClient = ApiService.httpClient;
      ApiService.httpClient = mockHttpClient;
      
      // Clear any cached auth data (this resets the cache too)
      await AuthService.clearAuth();
    });

    tearDown(() {
      // Restore original client
      ApiService.httpClient = originalClient;
      
      // Reset all mock expectations
      reset(mockHttpClient);
    });

    group('Complete Authentication Flow', () {
      test('should handle successful login flow through all layers', () async {
        // Arrange - Mock successful login API response
        final mockResponse = {
          'accessToken': 'integration_test_token_123',
          'user': {
            'id': 'user_123',
            'email': 'test@example.com',
            'firstName': 'John',
            'lastName': 'Doe',
            'role': 'paid_user',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        };

        when(mockHttpClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': 'test@example.com',
            'password': 'password123',
          }),
        )).thenAnswer((_) async => http.Response(
          json.encode(mockResponse),
          200,
        ));

        // Verify initial state
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.isLoading, isFalse);

        // Act - Call login through provider (full integration)
        final success = await authProvider.login('test@example.com', 'password123');

        // Assert - Verify complete integration success
        expect(success, isTrue);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user!.email, equals('test@example.com'));
        expect(authProvider.user!.fullName, equals('John Doe'));
        expect(authProvider.user!.isPaidUser, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);

        // Verify HTTP call was made correctly
        verify(mockHttpClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': 'test@example.com',
            'password': 'password123',
          }),
        )).called(1);

        // Verify token was persisted
        expect(await AuthService.getToken(), equals('integration_test_token_123'));
      });

      test('should handle login failure through all layers', () async {
        // Arrange - Mock failed login API response
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'message': 'Invalid credentials'}),
          401,
        ));

        // Act - Attempt login
        final success = await authProvider.login('test@example.com', 'wrongpassword');

        // Assert - Verify failed authentication
        expect(success, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, equals('Invalid email or password'));

        // Verify no token was stored
        expect(await AuthService.getToken(), isNull);
      });

      test('should handle network error during login', () async {
        // Arrange - Mock network exception
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network error'));

        // Act - Attempt login
        final success = await authProvider.login('test@example.com', 'password123');

        // Assert - Verify error handling
        expect(success, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, equals('Login failed. Please try again.'));
      });

      test('should handle complete logout flow', () async {
        // Arrange - First login successfully
        final mockLoginResponse = {
          'accessToken': 'logout_test_token',
          'user': {
            'id': 'user_123',
            'email': 'test@example.com',
            'role': 'free_user',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        };

        when(mockHttpClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(mockLoginResponse),
          200,
        ));

        // Login first
        final loginSuccess = await authProvider.login('test@example.com', 'password123');
        expect(loginSuccess, isTrue);
        expect(authProvider.isAuthenticated, isTrue);

        // Act - Logout through provider
        await authProvider.logout();

        // Assert - Verify complete state cleanup
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.errorMessage, isNull);
        expect(await AuthService.isAuthenticated(), isFalse);
        expect(await AuthService.getToken(), isNull);
      });

      test('should restore authentication state on initialization', () async {
        // Arrange - Simulate stored auth data from previous session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'stored_token_123');
        await prefs.setString('user_data', json.encode({
          'id': 'stored_user',
          'email': 'stored@example.com',
          'firstName': 'Stored',
          'role': 'paid_user',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        }));

        // Mock successful profile validation
        when(mockHttpClient.get(
          Uri.parse('${ApiService.baseUrl}/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer stored_token_123',
          },
        )).thenAnswer((_) async => http.Response(
          json.encode({
            'id': 'stored_user',
            'email': 'stored@example.com',
            'firstName': 'Stored',
            'role': 'paid_user',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }),
          200,
        ));

        // Act - Initialize provider (simulates app startup)
        await authProvider.initialize();

        // Assert - Should restore authentication state
        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user!.email, equals('stored@example.com'));
        expect(authProvider.user!.firstName, equals('Stored'));
        expect(authProvider.user!.isPaidUser, isTrue);

        // Verify profile endpoint was called for validation
        verify(mockHttpClient.get(
          Uri.parse('${ApiService.baseUrl}/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer stored_token_123',
          },
        )).called(1);
      });

      test('should handle token expiration during initialization', () async {
        // Arrange - Store auth data but mock token expiration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'expired_token');
        await prefs.setString('user_data', json.encode({
          'id': 'user_123',
          'email': 'test@example.com',
          'role': 'free_user',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        }));

        // Mock token expiration response
        when(mockHttpClient.get(
          Uri.parse('${ApiService.baseUrl}/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer expired_token',
          },
        )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // Act - Initialize with expired token
        await authProvider.initialize();

        // Assert - Should handle expiration gracefully
        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);

        // Verify expired auth data was cleared
        expect(prefs.getString('auth_token'), isNull);
        expect(prefs.getString('user_data'), isNull);
      });

      test('should handle registration flow through all layers', () async {
        // Arrange - Mock successful registration API response
        final mockResponse = {
          'accessToken': 'registration_token_456',
          'user': {
            'id': 'new_user_456',
            'email': 'newuser@example.com',
            'firstName': 'New',
            'lastName': 'User',
            'role': 'free_user',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        };

        when(mockHttpClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': 'newuser@example.com',
            'password': 'password123',
            'firstName': 'New',
            'lastName': 'User',
          }),
        )).thenAnswer((_) async => http.Response(
          json.encode(mockResponse),
          201,
        ));

        // Act - Register through provider
        final success = await authProvider.register(
          email: 'newuser@example.com',
          password: 'password123',
          firstName: 'New',
          lastName: 'User',
        );

        // Assert - Verify successful registration and auto-login
        expect(success, isTrue);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user!.email, equals('newuser@example.com'));
        expect(authProvider.user!.fullName, equals('New User'));
        expect(authProvider.user!.isPaidUser, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);

        // Verify token was persisted
        expect(await AuthService.getToken(), equals('registration_token_456'));
      });
    });

    group('Service Layer Integration', () {
      test('should integrate properly between AuthService and ApiService', () async {
        // Arrange - Mock API response
        final mockResponse = {
          'accessToken': 'service_test_token',
          'user': {
            'id': 'service_user',
            'email': 'service@example.com',
            'role': 'admin',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        };

        when(mockHttpClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(mockResponse),
          200,
        ));

        // Act - Call AuthService directly
        final request = LoginRequest(email: 'service@example.com', password: 'test123');
        final authResponse = await AuthService.login(request);

        // Assert - Verify service integration
        expect(authResponse, isNotNull);
        expect(authResponse!.accessToken, equals('service_test_token'));
        expect(authResponse.user.email, equals('service@example.com'));
        expect(authResponse.user.isAdmin, isTrue);

        // Verify token was stored by AuthService
        expect(await AuthService.getToken(), equals('service_test_token'));
        expect(await AuthService.isAuthenticated(), isTrue);
      });
    });
  });
}