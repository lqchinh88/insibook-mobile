import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'api_service.dart';
import 'token_service.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static User? _cachedUser;

  // Get stored token - delegate to TokenService
  static Future<String?> getToken() async {
    return TokenService.getToken();
  }

  // Get stored user
  static Future<User?> getUser() async {
    if (_cachedUser != null) return _cachedUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        _cachedUser = User.fromJson(json.decode(userJson));
      } catch (e) {
        // If parsing fails, clear the stored data
        await clearAuth();
      }
    }
    return _cachedUser;
  }

  // Store authentication data
  static Future<void> saveAuth(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    _cachedUser = authResponse.user;
    
    await TokenService.setToken(authResponse.accessToken);
    await prefs.setString(_userKey, json.encode({
      'id': authResponse.user.id,
      'email': authResponse.user.email,
      'firstName': authResponse.user.firstName,
      'lastName': authResponse.user.lastName,
      'role': authResponse.user.role,
      'isActive': authResponse.user.isActive,
      'createdAt': authResponse.user.createdAt.toIso8601String(),
      'updatedAt': authResponse.user.updatedAt.toIso8601String(),
    }));
  }

  // Clear authentication data
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    
    _cachedUser = null;
    
    await TokenService.clearToken();
    await prefs.remove(_userKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return TokenService.hasToken();
  }

  // Register a new user
  static Future<AuthResponse?> register(RegisterRequest request) async {
    final response = await ApiService.post('/auth/register', body: request.toJson());

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);
      await saveAuth(authResponse);
      return authResponse;
    } else {
      // Registration failed
      return null;
    }
  }

  // Login user
  static Future<AuthResponse?> login(LoginRequest request) async {
    final response = await ApiService.post('/auth/login', body: request.toJson());

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(jsonData);
      await saveAuth(authResponse);
      return authResponse;
    } else {
      // Login failed (invalid credentials, etc.)
      return null;
    }
  }

  // Logout user
  static Future<void> logout() async {
    await clearAuth();
  }

  // Get user profile (refresh user data)
  static Future<User?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await ApiService.get('/auth/profile');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final user = User.fromJson(jsonData);
      
      // Update cached user
      _cachedUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode({
        'id': user.id,
        'email': user.email,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'role': user.role,
        'isActive': user.isActive,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
      }));
      
      return user;
    } else if (response.statusCode == 401) {
      // Token expired or invalid, clear auth
      await clearAuth();
      return null;
    } else {
      return null;
    }
  }
}