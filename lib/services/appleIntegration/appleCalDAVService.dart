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


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Connection failed: ${response.statusCode}');
        
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


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final calendars = data['data'] as List?;
        
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleCalDAVService] Failed to fetch calendars: ${response.statusCode}');
        
        try {
          final errorData = jsonDecode(errorBody);
          throw Exception(errorData['message'] ?? 'Error fetching calendars');
        } catch (jsonError) {
          throw Exception('Error fetching calendars');
        }
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

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        print('❌ [AppleCalDAVService] No authentication token available');
        throw Exception('No authentication token available');
      }

      final requestBody = {
        'email': email,
        'calendars': calendars,
      };
      
      print('📤 [AppleCalDAVService] Final request body being sent to backend:');
      print('  📧 Email: $email');
      print('  📊 Calendars count: ${calendars.length}');
      for (int i = 0; i < calendars.length; i++) {
        final cal = calendars[i];
        print('  📋 [FINAL APPLE] Calendar $i: "${cal['summary'] ?? cal['title']}"');
        print('    🆔 ID: ${cal['id']}');
        print('    🔗 Provider ID: ${cal['providerCalendarId']}');
        print('    📊 Source: ${cal['source']}');
        print('    🏷️ FINAL category: "${cal['category']}"');
        print('    ✅ importAll: ${cal['importAll']}');
        print('    📝 importSubject: ${cal['importSubject']}');
        print('    🔄 Structure: ${cal.containsKey('preferences') ? 'NESTED (has preferences)' : 'FLATTENED (no preferences)'}');
      }
      print('📤 [AppleCalDAVService] Sending to: ${Config.backendURL}/apple/calendars/save');

      final response = await _apiClient.post(
        '${Config.backendURL}/apple/calendars/save',
        body: requestBody,
        token: authToken,
      );



      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.delete(
        '${Config.backendURL}/apple/calendars/delete',
        token: authToken,
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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