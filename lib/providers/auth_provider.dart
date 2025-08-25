import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // Initialize auth state from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _user = await AuthService.getUser();
      
      // Validate token by fetching profile
      if (_user != null) {
        final profile = await AuthService.getProfile();
        if (profile == null) {
          // Token is invalid, clear auth
          _user = null;
        } else {
          _user = profile;
        }
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await AuthService.login(request);

      if (response != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      _isLoading = false;
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
    _isLoading = true;
    _errorMessage = null;
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
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed. Email may already exist.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
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
}