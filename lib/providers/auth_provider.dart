import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

enum AuthState {
  idle,
  loading,
  loginSuccess,
  loginFailedInvalidCredentials,
  loginFailedNetworkError,
  registerSuccess,
  registerFailedEmailExists,
  registerFailedNetworkError,
  initializationFailed,
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isInitialized = false;
  AuthState _authState = AuthState.idle;

  User? get user => _user;
  bool get isLoading => _authState == AuthState.loading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  AuthState get authState => _authState;

  // Initialize auth state from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _authState = AuthState.loading;
    notifyListeners();

    try {
      _user = await AuthService.getUser();
      
      // Validate token by fetching profile
      if (_user != null) {
        final profile = await AuthService.getProfile();
        if (profile == null) {
          // Token is invalid, clear auth
          _user = null;
          _authState = AuthState.idle;
        } else {
          _user = profile;
          _authState = AuthState.idle;
        }
      } else {
        _authState = AuthState.idle;
      }
    } catch (e) {
      _user = null;
      _authState = AuthState.initializationFailed;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await AuthService.login(request);

      if (response != null) {
        _user = response.user;
        _authState = AuthState.loginSuccess;
        notifyListeners();
        return true;
      } else {
        _authState = AuthState.loginFailedInvalidCredentials;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authState = AuthState.loginFailedNetworkError;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      final response = await AuthService.register(request);

      if (response != null) {
        _user = response.user;
        _authState = AuthState.registerSuccess;
        notifyListeners();
        return true;
      } else {
        _authState = AuthState.registerFailedEmailExists;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authState = AuthState.registerFailedNetworkError;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _authState = AuthState.idle;
    notifyListeners();
  }

  // Clear auth state (reset to idle)
  void clearState() {
    _authState = AuthState.idle;
    notifyListeners();
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;

    try {
      final profile = await AuthService.getProfile();
      if (profile != null) {
        _user = profile;
        notifyListeners();
      } else {
        // Token is invalid, logout
        await logout();
      }
    } catch (e) {
      // Silently fail, keep current user state
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    if (!isAuthenticated) return false;

    _authState = AuthState.loading;
    notifyListeners();

    try {
      final success = await AuthService.deleteAccount();

      if (success) {
        _user = null;
        _authState = AuthState.idle;
        notifyListeners();
        return true;
      } else {
        _authState = AuthState.loginFailedNetworkError;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authState = AuthState.loginFailedNetworkError;
      notifyListeners();
      return false;
    }
  }
}