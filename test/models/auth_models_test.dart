import 'package:flutter_test/flutter_test.dart';
import 'package:insibook_mobile/models/auth_models.dart';

void main() {
  group('User Model', () {
    group('user properties', () {
      test('user should have correct properties', () {
        final user = User(
          id: 'user_123',
          email: 'john.doe@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'paid_user',
          isActive: true,
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        expect(user.fullName, equals('John Doe'));
        expect(user.isAdmin, isFalse);
        expect(user.isPaidUser, isTrue);
      });

      test('admin user should have correct permissions', () {
        final adminUser = User(
          id: 'admin_123',
          email: 'admin@example.com',
          role: 'admin',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(adminUser.isAdmin, isTrue);
        expect(adminUser.isPaidUser, isTrue);
      });

      test('owner user should have correct permissions', () {
        final ownerUser = User(
          id: 'owner_123',
          email: 'owner@example.com',
          role: 'owner',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(ownerUser.isAdmin, isTrue);
        expect(ownerUser.isPaidUser, isTrue);
      });

      test('free user should have correct permissions', () {
        final freeUser = User(
          id: 'free_123',
          email: 'free@example.com',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(freeUser.isAdmin, isFalse);
        expect(freeUser.isPaidUser, isFalse);
      });

      test('user fullName should handle different name combinations', () {
        // Both names
        final fullNameUser = User(
          id: '1',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(fullNameUser.fullName, equals('John Doe'));

        // First name only
        final firstNameUser = User(
          id: '2',
          email: 'test2@example.com',
          firstName: 'Jane',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(firstNameUser.fullName, equals('Jane'));

        // Last name only
        final lastNameUser = User(
          id: '3',
          email: 'test3@example.com',
          lastName: 'Smith',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(lastNameUser.fullName, equals('Smith'));

        // No names - should return email
        final emailUser = User(
          id: '4',
          email: 'test4@example.com',
          role: 'free_user',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(emailUser.fullName, equals('test4@example.com'));
      });
    });

    group('request models', () {
      test('LoginRequest should serialize correctly', () {
        final loginRequest = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );

        final json = loginRequest.toJson();
        expect(json['email'], equals('test@example.com'));
        expect(json['password'], equals('password123'));
      });

      test('RegisterRequest should serialize correctly', () {
        final registerRequest = RegisterRequest(
          email: 'new@example.com',
          password: 'password123',
          firstName: 'John',
          lastName: 'Doe',
        );

        final json = registerRequest.toJson();
        expect(json['email'], equals('new@example.com'));
        expect(json['password'], equals('password123'));
        expect(json['firstName'], equals('John'));
        expect(json['lastName'], equals('Doe'));
      });

      test('RegisterRequest should handle optional names', () {
        final registerRequest = RegisterRequest(
          email: 'new@example.com',
          password: 'password123',
        );

        final json = registerRequest.toJson();
        expect(json['email'], equals('new@example.com'));
        expect(json['password'], equals('password123'));
        expect(json.containsKey('firstName'), isFalse);
        expect(json.containsKey('lastName'), isFalse);
      });
    });

    group('JSON deserialization', () {
      test('User should deserialize from JSON correctly', () {
        final json = {
          'id': 'user_123',
          'email': 'test@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'role': 'paid_user',
          'isActive': true,
          'createdAt': '2024-01-01T10:30:00.000Z',
          'updatedAt': '2024-01-01T11:00:00.000Z',
        };

        final user = User.fromJson(json);
        
        expect(user.id, equals('user_123'));
        expect(user.email, equals('test@example.com'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.role, equals('paid_user'));
        expect(user.isActive, isTrue);
        expect(user.createdAt, equals(DateTime.parse('2024-01-01T10:30:00.000Z')));
        expect(user.updatedAt, equals(DateTime.parse('2024-01-01T11:00:00.000Z')));
      });

      test('AuthResponse should deserialize from JSON correctly', () {
        final json = {
          'accessToken': 'token_123',
          'user': {
            'id': 'user_123',
            'email': 'test@example.com',
            'role': 'free_user',
            'isActive': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'updatedAt': '2024-01-01T00:00:00.000Z',
          }
        };

        final authResponse = AuthResponse.fromJson(json);
        
        expect(authResponse.accessToken, equals('token_123'));
        expect(authResponse.user.id, equals('user_123'));
        expect(authResponse.user.email, equals('test@example.com'));
        expect(authResponse.user.role, equals('free_user'));
      });

      test('User should handle malformed JSON gracefully', () {
        final json = <String, dynamic>{
          // Missing required fields
          'role': 'free_user',
        };

        final user = User.fromJson(json);
        
        expect(user.id, equals(''));
        expect(user.email, equals(''));
        expect(user.role, equals('free_user'));
        expect(user.isActive, isFalse);
      });
    });
  });
}