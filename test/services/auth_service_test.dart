import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/services/auth_service.dart';
import 'package:insibook_mobile/models/auth_models.dart';

void main() {
  group('AuthService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('token management', () {
      test('should save and retrieve token correctly', () async {
        // Arrange
        final authResponse = AuthResponse(
          accessToken: 'test_token_123',
          user: User(
            id: 'user_123',
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            role: 'free_user',
            isActive: true,
            createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          ),
        );

        // Act
        await AuthService.saveAuth(authResponse);
        final savedToken = await AuthService.getToken();
        final savedUser = await AuthService.getUser();

        // Assert
        expect(savedToken, equals('test_token_123'));
        expect(savedUser, isNotNull);
        expect(savedUser!.email, equals('test@example.com'));
        expect(savedUser.firstName, equals('John'));
        expect(savedUser.role, equals('free_user'));
      });

      test('should clear auth data correctly', () async {
        // Arrange
        final authResponse = AuthResponse(
          accessToken: 'test_token_123',
          user: User(
            id: 'user_123',
            email: 'test@example.com',
            role: 'free_user',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await AuthService.saveAuth(authResponse);

        // Act
        await AuthService.clearAuth();
        final token = await AuthService.getToken();
        final user = await AuthService.getUser();

        // Assert
        expect(token, isNull);
        expect(user, isNull);
      });

      test('should return correct authentication status', () async {
        // Test unauthenticated state
        expect(await AuthService.isAuthenticated(), isFalse);

        // Test authenticated state
        final authResponse = AuthResponse(
          accessToken: 'test_token_123',
          user: User(
            id: 'user_123',
            email: 'test@example.com',
            role: 'free_user',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await AuthService.saveAuth(authResponse);
        expect(await AuthService.isAuthenticated(), isTrue);
      });
    });
  });
}