import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';

/// Service for Apple Calendar CalDAV integration
/// Uses Apple ID + App-Specific Password instead of OAuth
class AppleCalDAVService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Connects to Apple Calendar using Apple ID and App-Specific Password
  Future<Map<String, dynamic>> connectAppleCalendar({
    required String appleId,
    required String appPassword,
  }) async {
    print('🔍 [AppleCalDAVService] Connecting to Apple Calendar');
    print('🔍 [AppleCalDAVService] Apple ID: $appleId');
    print('🔍 [AppleCalDAVService] App Password length: ${appPassword.length}');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        '${Config.backendURL}/apple/auth',
        body: {
          'appleId': appleId,
          'appPassword': appPassword,
        },
        token: authToken,
      );

      print('🔍 [AppleCalDAVService] Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AppleCalDAVService] Apple Calendar connected successfully');
        print('🔍 [AppleCalDAVService] Calendars available: ${data['calendarsCount'] ?? 0}');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Connection failed: ${response.statusCode}');
        print('🔍 [AppleCalDAVService] Error response: $errorBody');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['message'] ?? 'Failed to connect Apple Calendar');
      }
    } catch (e) {
      print('❌ [AppleCalDAVService] Exception connecting Apple Calendar: $e');
      rethrow;
    }
  }

  /// Fetches Apple calendars for the connected account
  Future<Map<String, dynamic>> fetchAppleCalendars(String email) async {
    print('🔍 [AppleCalDAVService] Fetching Apple calendars for: $email');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        '${Config.backendURL}/apple/calendars/fetch',
        body: {
          'email': email,
        },
        token: authToken,
      );

      print('🔍 [AppleCalDAVService] Fetch calendars response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final calendars = data['data'] as List?;
        
        print('✅ [AppleCalDAVService] Fetched ${calendars?.length ?? 0} Apple calendars');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Failed to fetch calendars: ${response.statusCode}');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['message'] ?? 'Failed to fetch Apple calendars');
      }
    } catch (e) {
      print('❌ [AppleCalDAVService] Exception fetching calendars: $e');
      rethrow;
    }
  }

  /// Saves selected Apple calendars and their events
  Future<Map<String, dynamic>> saveSelectedCalendars({
    required String email,
    required List<Map<String, dynamic>> calendars,
  }) async {
    print('🔍 [AppleCalDAVService] Saving ${calendars.length} selected calendars');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        '${Config.backendURL}/apple/calendars/save',
        body: {
          'email': email,
          'calendars': calendars,
        },
        token: authToken,
      );

      print('🔍 [AppleCalDAVService] Save calendars response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AppleCalDAVService] Apple calendars and events saved successfully');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Failed to save calendars: ${response.statusCode}');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['message'] ?? 'Failed to save Apple calendars');
      }
    } catch (e) {
      print('❌ [AppleCalDAVService] Exception saving calendars: $e');
      rethrow;
    }
  }

  /// Deletes Apple calendars for the user
  Future<Map<String, dynamic>> deleteAppleCalendars() async {
    print('🔍 [AppleCalDAVService] Deleting Apple calendars');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.delete(
        '${Config.backendURL}/apple/calendars/delete',
        token: authToken,
      );

      print('🔍 [AppleCalDAVService] Delete calendars response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AppleCalDAVService] Apple calendars deleted successfully');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Failed to delete calendars: ${response.statusCode}');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['message'] ?? 'Failed to delete Apple calendars');
      }
    } catch (e) {
      print('❌ [AppleCalDAVService] Exception deleting calendars: $e');
      rethrow;
    }
  }

  /// Disconnects Apple account
  Future<Map<String, dynamic>> disconnectAppleAccount(String email) async {
    print('🔍 [AppleCalDAVService] Disconnecting Apple account: $email');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.delete(
        '${Config.backendURL}/apple/accounts/delete',
        body: {
          'email': email,
        },
        token: authToken,
      );

      print('🔍 [AppleCalDAVService] Disconnect account response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AppleCalDAVService] Apple account disconnected successfully');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Failed to disconnect account: ${response.statusCode}');
        
        final errorData = jsonDecode(errorBody);
        throw Exception(errorData['message'] ?? 'Failed to disconnect Apple account');
      }
    } catch (e) {
      print('❌ [AppleCalDAVService] Exception disconnecting account: $e');
      rethrow;
    }
  }

  /// Validates Apple ID format
  bool isValidAppleId(String appleId) {
    if (appleId.isEmpty) return false;
    
    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(appleId);
  }

  /// Validates App-Specific Password format
  bool isValidAppPassword(String appPassword) {
    if (appPassword.isEmpty) return false;
    
    // Remove dashes and check if it's 16 alphanumeric characters
    final cleanPassword = appPassword.replaceAll('-', '');
    return cleanPassword.length == 16 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(cleanPassword);
  }

  /// Formats app-specific password with dashes (xxxx-xxxx-xxxx-xxxx)
  String formatAppPassword(String password) {
    final clean = password.replaceAll('-', '');
    if (clean.length != 16) return password;
    
    return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-${clean.substring(8, 12)}-${clean.substring(12, 16)}';
  }
}