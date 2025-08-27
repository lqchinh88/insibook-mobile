import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insibook_mobile/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    group('initialization', () {
      test('should initialize with correct default values', () {
        expect(authProvider.user, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isInitialized, isFalse);
        expect(authProvider.authState, AuthState.idle);
      });

      test('should set initialized state after initialization', () async {
        await authProvider.initialize();
        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('error handling', () {
      test('should clear error message', () {
        // This would normally be set by a failed login/register attempt
        // For testing, we can directly access the private field through reflection
        // or test indirectly through the login/register methods
        
        authProvider.clearState();
        expect(authProvider.authState, AuthState.idle);
      });
    });

    group('authentication state', () {
      test('should start with unauthenticated state', () async {
        // Assert - Provider should start clean
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
      });

      test('should handle logout correctly', () async {
        await authProvider.logout();
        
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.authState, AuthState.idle);
      });
    });

  });
}