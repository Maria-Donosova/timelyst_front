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
    print('🔍 [MicrosoftCalendarService] Fetching calendars page for email: $email');
    print('🔍 [MicrosoftCalendarService] Page size: $pageSize, Page token: $pageToken');

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
        print('✅ [MicrosoftCalendarService] Successfully fetched calendars page');
        print('🔍 [MicrosoftCalendarService] Calendars count: ${(data['calendars'] as List?)?.length ?? 0}');
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
    print('🔍 [MicrosoftCalendarService] Saving ${calendars.length} selected calendars');
    print('🔍 [MicrosoftCalendarService] User: $userId, Email: $email');

    try {
      final response = await _apiClient.post(
        Config.backendMicrosoftCalendarsSave,
        body: {
          'user': userId,
          'email': email,
          'calendars': calendars.map((c) => c.toJson(email: email)).toList(),
          'batchSize': calendars.length,
        },
        token: await _authService.getAuthToken(),
      );

      _handleBatchResponse(response);
      print('✅ [MicrosoftCalendarService] Successfully saved calendars batch');
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
    print('🔍 [MicrosoftCalendarService] Fetching calendar changes for email: $email');
    print('🔍 [MicrosoftCalendarService] Sync token: $syncToken');

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
        print('✅ [MicrosoftCalendarService] Successfully fetched calendar changes');
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
      print('✅ [MicrosoftCalendarService] Batch operation successful');
      print('🔍 [MicrosoftCalendarService] Response: $data');
    } else {
      print('❌ [MicrosoftCalendarService] Batch operation failed: ${response.statusCode}');
      print('🔍 [MicrosoftCalendarService] Error response: ${response.body}');
      throw Exception('Failed to save Microsoft calendars: ${response.statusCode}');
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
    print('🔍 [MicrosoftCalendarService] Getting all calendars for email: $email');
    
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
        
        print('🔍 [MicrosoftCalendarService] Fetched page $pageCount with ${calendarsData?.length ?? 0} calendars');
        
      } while (nextPageToken != null && pageCount < maxPages);

      print('✅ [MicrosoftCalendarService] Successfully fetched ${allCalendars.length} total calendars');
      return allCalendars;
      
    } catch (e) {
      print('❌ [MicrosoftCalendarService] Error getting all calendars: $e');
      rethrow;
    }
  }
}