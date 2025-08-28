import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';

class AuthService {
  static const String _authTokenKey = 'authToken';
  static const String _userIdKey = 'userId';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final String query = '''
      mutation UserLogin(\$email: String!, \$password: String!) {
        userLogin(email: \$email, password: \$password) {
          token
          userId
          role
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'email': email,
      'password': password,
    };

    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      body: {'query': query, 'variables': variables},
      token: await getAuthToken(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        throw Exception(
            'Login failed: ${data['errors'].map((e) => e['message']).join(", ")}');
      }
      final loginData = data['data']['userLogin'];
      await saveAuthToken(loginData['token']);
      await saveUserId(loginData['userId']);
      return loginData;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password,
      String name, String lastName, bool consent) async {
    final String query = '''
      mutation RegisterUser(\$email: String!, \$name: String!, \$lastName: String!, \$password: String!, \$consent: Boolean!) {
        registerUser(userInput: {email: \$email, name: \$name, last_name: \$lastName, password: \$password, consent: \$consent}) {
          token
          userId
          role
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'email': email,
      'name': name,
      'lastName': lastName,
      'password': password,
      'consent': consent,
    };

    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      body: {'query': query, 'variables': variables},
      token: await getAuthToken(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        throw Exception(
            'Registration failed: ${data['errors'].map((e) => e['message']).join(", ")}');
      }
      final registerData = data['data']['registerUser'];
      await saveAuthToken(registerData['token']);
      await saveUserId(registerData['userId']);
      return registerData;
    } else {
      throw Exception('Failed to signup: ${response.statusCode}');
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