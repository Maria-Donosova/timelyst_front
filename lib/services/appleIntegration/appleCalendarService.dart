import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

class AppleCalendarService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Fetches Apple calendars page by page
  Future<Map<String, dynamic>> fetchCalendarsPage({
    required String email,
    int pageSize = 20,
    String? pageToken,
  }) async {

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        Config.backendAppleCalendarsFetch,
        body: {
          'email': email,
          'pageSize': pageSize,
          'pageToken': pageToken,
        },
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ [AppleCalendarService] Failed to fetch calendars: ${response.statusCode}');
        throw Exception(
          'Failed to load calendars page: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [AppleCalendarService] Exception fetching calendars: $e');
      rethrow;
    }
  }

  /// Saves selected Apple calendars to backend
  Future<void> saveCalendarsBatch({
    required String userId,
    required String email,
    required List<Calendar> calendars,
  }) async {

    try {
      final response = await _apiClient.post(
        Config.backendAppleCalendarsSave,
        body: {
          'user': userId,
          'email': email,
          'calendars': calendars.map((c) => c.toJson(email: email)).toList(),
          'batchSize': calendars.length,
        },
        token: await _authService.getAuthToken(),
      );

      _handleBatchResponse(response);
    } catch (e) {
      print('❌ [AppleCalendarService] Error saving calendars: $e');
      throw _handleError('saving calendars', e);
    }
  }

  /// Fetches calendar changes/updates (for sync)
  Future<Map<String, dynamic>> fetchCalendarChanges({
    required String email,
    String? syncToken,
  }) async {

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        Config.backendAppleCalendarsFetch,
        body: {
          'email': email,
          'syncToken': syncToken,
          'changesOnly': true,
        },
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ [AppleCalendarService] Failed to fetch changes: ${response.statusCode}');
        throw Exception(
          'Failed to fetch calendar changes: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [AppleCalendarService] Exception fetching changes: $e');
      rethrow;
    }
  }

  /// Handles batch response from save operations
  void _handleBatchResponse(response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    } else {
      print('❌ [AppleCalendarService] Batch operation failed: ${response.statusCode}');
      throw Exception('Failed to save Apple calendars: ${response.statusCode}');
    }
  }

  /// Handles and formats errors
  Exception _handleError(String operation, dynamic error) {
    final errorMessage = 'Failed $operation: ${error.toString()}';
    print('❌ [AppleCalendarService] $errorMessage');
    return Exception(errorMessage);
  }

  /// Gets all Apple calendars for a user (with pagination)
  Future<List<Calendar>> getAllCalendars({
    required String email,
    int maxPages = 10,
  }) async {
    
    List<Calendar> allCalendars = [];
    String? nextPageToken;
    int pageCount = 0;

    try {
      do {
        final pageData = await fetchCalendarsPage(
          email: email,
          pageToken: nextPageToken,
        );

        final calendarsData = pageData['calendars'] as List?;
        if (calendarsData != null) {
          final pageCalendars = calendarsData
              .map((json) => Calendar.fromAppleJson(json))
              .toList();
          allCalendars.addAll(pageCalendars);
        }

        nextPageToken = pageData['nextPageToken'];
        pageCount++;
        
        
      } while (nextPageToken != null && pageCount < maxPages);

      return allCalendars;
      
    } catch (e) {
      print('❌ [AppleCalendarService] Error getting all calendars: $e');
      rethrow;
    }
  }
}