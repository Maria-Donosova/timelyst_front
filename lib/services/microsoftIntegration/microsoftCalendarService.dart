import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

class MicrosoftCalendarService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Fetches Microsoft calendars page by page
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
        Config.backendMicrosoftCalendarsFetch,
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
        print('❌ [MicrosoftCalendarService] Failed to fetch calendars: ${response.statusCode}');
        throw Exception(
          'Failed to load calendars page: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [MicrosoftCalendarService] Exception fetching calendars: $e');
      rethrow;
    }
  }

  /// Saves selected Microsoft calendars to backend
  Future<void> saveCalendarsBatch({
    required String userId,
    required String email,
    required List<Calendar> calendars,
  }) async {

    // Debug: Print each calendar being sent
    for (int i = 0; i < calendars.length; i++) {
      final calendar = calendars[i];
      print('📅 [MicrosoftCalendarService] Calendar $i: "${calendar.metadata.title}"');
      print('  📋 Source: ${calendar.source}');
      print('  📋 Provider ID: ${calendar.providerCalendarId}');
      print('  📋 Import All: ${calendar.preferences.importSettings.importAll}');
      print('  📋 Import Subject: ${calendar.preferences.importSettings.importSubject}');
      print('  📋 Category: ${calendar.preferences.category}');
    }

    final requestBody = {
      'user': userId,
      'email': email,
      'calendars': calendars.map((c) {
        final json = c.toJson(email: email);
        // Flatten all preferences for consistent backend structure
        final importSettings = json['preferences']['importSettings'];
        final preferences = json['preferences'];
        json.addAll({
          'importAll': importSettings['importAll'],
          'importSubject': importSettings['importSubject'],
          'importBody': importSettings['importBody'],
          'importConferenceInfo': importSettings['importConferenceInfo'],
          'importOrganizer': importSettings['importOrganizer'],
          'importRecipients': importSettings['importRecipients'],
          'category': preferences['category'],
          'color': preferences['color'],
        });
        // Remove nested preferences object to avoid duplication
        json.remove('preferences');
        return json;
      }).toList(),
      'batchSize': calendars.length,
    };

    print('📋 URL: ${Config.backendMicrosoftCalendarsSave}');
    print('📋 Body: ${jsonEncode(requestBody)}');

    try {
      final response = await _apiClient.post(
        Config.backendMicrosoftCalendarsSave,
        body: requestBody,
        token: await _authService.getAuthToken(),
      );

      _handleBatchResponse(response);
    } catch (e) {
      print('❌ [MicrosoftCalendarService] Error saving calendars: $e');
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
        Config.backendMicrosoftCalendarsFetch,
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
        print('❌ [MicrosoftCalendarService] Failed to fetch changes: ${response.statusCode}');
        throw Exception(
          'Failed to fetch calendar changes: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [MicrosoftCalendarService] Exception fetching changes: $e');
      rethrow;
    }
  }

  /// Handles batch response from save operations
  void _handleBatchResponse(response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    } else {
      print('❌ [MicrosoftCalendarService] Batch operation failed: ${response.statusCode}');
      
      // Try to parse error details
      try {
        final errorData = jsonDecode(response.body);
      } catch (e) {
      }
      
      throw Exception('Failed to save Microsoft calendars: ${response.statusCode} - ${response.body}');
    }
  }

  /// Handles and formats errors
  Exception _handleError(String operation, dynamic error) {
    final errorMessage = 'Failed $operation: ${error.toString()}';
    print('❌ [MicrosoftCalendarService] $errorMessage');
    return Exception(errorMessage);
  }

  /// Gets all Microsoft calendars for a user (with pagination)
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
              .map((json) => Calendar.fromMicrosoftJson(json))
              .toList();
          allCalendars.addAll(pageCalendars);
        }

        nextPageToken = pageData['nextPageToken'];
        pageCount++;
        
        
      } while (nextPageToken != null && pageCount < maxPages);

      return allCalendars;
      
    } catch (e) {
      print('❌ [MicrosoftCalendarService] Error getting all calendars: $e');
      rethrow;
    }
  }
}