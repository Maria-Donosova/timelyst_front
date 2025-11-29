import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';

class AuthService {
  static const String _authTokenKey = 'authToken';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  late final FlutterSecureStorage _storage;
  late final ApiClient _apiClient;

  AuthService() {
    _storage = FlutterSecureStorage();
    _apiClient = ApiClient();
  }

  AuthService.test(this._apiClient, this._storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      '${Config.backendURL}/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];
      
      await saveAuthToken(token);
      await saveUserId(user['id']);
      await saveUserEmail(email); 
      
      return data;
    } else {
      throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password,
      String name, String lastName, bool consent) async {
    final response = await _apiClient.post(
      '${Config.backendURL}/auth/register',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'lastName': lastName,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = data['user'];
      
      await saveAuthToken(token);
      await saveUserId(user['id']);
      await saveUserEmail(email);
      
      return data;
    } else {
      throw Exception('Failed to register: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      print('Error saving auth token: $e');
      rethrow;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('Error saving userId: $e');
      rethrow;
    }
  }

  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (e) {
      print('Error saving user email: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading userId: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
    } catch (e) {
      print('Error clearing auth token: $e');
      rethrow;
    }
  }

  Future<void> clearUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (e) {
      print('Error clearing userId: $e');
      rethrow;
    }
  }

  Future<void> clearUserEmail() async {
    try {
      await _storage.delete(key: _userEmailKey);
    } catch (e) {
      print('Error clearing user email: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await clearAuthToken();
      await clearUserId();
      await clearUserEmail();
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}