import 'dart:convert';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/customApp.dart';
import 'package:timelyst_flutter/models/timeEvent.dart';
import 'package:timelyst_flutter/models/dayEvent.dart';
import 'package:timelyst_flutter/utils/eventsMapper.dart';

class GoogleEventsImportService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Imports events from all selected Google calendars
  Future<GoogleEventsImportResult> importAllCalendarEvents({
    required String userId,
    required String email,
    String? syncToken,
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    print('🔄 [GoogleEventsImportService] Starting import for user: $userId, email: $email');
    
    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      // Set default time range if not provided (import last 6 months + next 12 months)
      timeMin ??= DateTime.now().subtract(const Duration(days: 180));
      timeMax ??= DateTime.now().add(const Duration(days: 365));

      final response = await _apiClient.post(
        '${Config.backendURL}/google/events/import',
        body: {
          'userId': userId,
          'email': email,
          'syncToken': syncToken,
          'timeMin': timeMin.toIso8601String(),
          'timeMax': timeMax.toIso8601String(),
          'includeRecurring': true, // Important for recurring events
          'expandRecurring': true,  // Expand recurring events into individual instances
        },
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [GoogleEventsImportService] Import successful');
        print('🔍 [GoogleEventsImportService] Response: ${data.keys.toList()}');
        
        return GoogleEventsImportResult.fromJson(data);
      } else {
        print('❌ [GoogleEventsImportService] Import failed: ${response.statusCode}');
        throw Exception(
          'Failed to import Google Calendar events: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [GoogleEventsImportService] Exception during import: $e');
      rethrow;
    }
  }

  /// Imports events from a specific Google calendar
  Future<GoogleEventsImportResult> importCalendarEvents({
    required String userId,
    required String email,
    required String calendarId,
    String? syncToken,
    DateTime? timeMin,
    DateTime? timeMax,
  }) async {
    print('🔄 [GoogleEventsImportService] Importing events from calendar: $calendarId');
    
    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      // Set default time range if not provided
      timeMin ??= DateTime.now().subtract(const Duration(days: 180));
      timeMax ??= DateTime.now().add(const Duration(days: 365));

      final response = await _apiClient.post(
        '${Config.backendURL}/google/events/import/calendar',
        body: {
          'userId': userId,
          'email': email,
          'calendarId': calendarId,
          'syncToken': syncToken,
          'timeMin': timeMin.toIso8601String(),
          'timeMax': timeMax.toIso8601String(),
          'includeRecurring': true,
          'expandRecurring': true,
        },
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [GoogleEventsImportService] Calendar import successful');
        
        return GoogleEventsImportResult.fromJson(data);
      } else {
        print('❌ [GoogleEventsImportService] Calendar import failed: ${response.statusCode}');
        throw Exception(
          'Failed to import events from calendar: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [GoogleEventsImportService] Exception during calendar import: $e');
      rethrow;
    }
  }

  /// Performs incremental sync of Google Calendar events
  Future<GoogleEventsImportResult> syncCalendarEvents({
    required String userId,
    required String email,
    required String syncToken,
  }) async {
    print('🔄 [GoogleEventsImportService] Syncing events with token: ${syncToken.substring(0, 10)}...');
    
    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        '${Config.backendURL}/google/events/sync',
        body: {
          'userId': userId,
          'email': email,
          'syncToken': syncToken,
          'includeRecurring': true,
        },
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [GoogleEventsImportService] Sync successful');
        
        return GoogleEventsImportResult.fromJson(data);
      } else if (response.statusCode == 410) {
        // Sync token expired, fall back to full import
        print('⚠️ [GoogleEventsImportService] Sync token expired, performing full import');
        return await importAllCalendarEvents(
          userId: userId,
          email: email,
        );
      } else {
        print('❌ [GoogleEventsImportService] Sync failed: ${response.statusCode}');
        throw Exception(
          'Failed to sync Google Calendar events: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [GoogleEventsImportService] Exception during sync: $e');
      rethrow;
    }
  }

  /// Gets the mapped events as CustomAppointments for immediate UI use
  Future<List<CustomAppointment>> getImportedEventsAsAppointments({
    required String userId,
    required String email,
  }) async {
    print('🔄 [GoogleEventsImportService] Fetching imported events as appointments');
    
    try {
      final importResult = await importAllCalendarEvents(
        userId: userId,
        email: email,
      );

      final appointments = <CustomAppointment>[];
      
      // Convert imported time events to appointments
      if (importResult.timeEvents != null) {
        for (final timeEventData in importResult.timeEvents!) {
          try {
            final timeEvent = TimeEvent.fromJson(timeEventData);
            final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);
            appointments.add(appointment);
          } catch (e) {
            print('⚠️ [GoogleEventsImportService] Error mapping time event: $e');
          }
        }
      }

      // Convert imported day events to appointments
      if (importResult.dayEvents != null) {
        for (final dayEventData in importResult.dayEvents!) {
          try {
            final dayEvent = DayEvent.fromJson(dayEventData);
            final appointment = EventMapper.mapDayEventToCustomAppointment(dayEvent);
            appointments.add(appointment);
          } catch (e) {
            print('⚠️ [GoogleEventsImportService] Error mapping day event: $e');
          }
        }
      }

      print('✅ [GoogleEventsImportService] Mapped ${appointments.length} events to appointments');
      return appointments;
      
    } catch (e) {
      print('❌ [GoogleEventsImportService] Error getting imported events: $e');
      rethrow;
    }
  }
}

class GoogleEventsImportResult {
  final bool success;
  final String? message;
  final int? importedCount;
  final int? updatedCount;
  final int? deletedCount;
  final String? nextSyncToken;
  final List<Map<String, dynamic>>? timeEvents;
  final List<Map<String, dynamic>>? dayEvents;
  final List<String>? errors;

  GoogleEventsImportResult({
    required this.success,
    this.message,
    this.importedCount,
    this.updatedCount,
    this.deletedCount,
    this.nextSyncToken,
    this.timeEvents,
    this.dayEvents,
    this.errors,
  });

  factory GoogleEventsImportResult.fromJson(Map<String, dynamic> json) {
    return GoogleEventsImportResult(
      success: json['success'] ?? false,
      message: json['message'],
      importedCount: json['importedCount'],
      updatedCount: json['updatedCount'],
      deletedCount: json['deletedCount'],
      nextSyncToken: json['nextSyncToken'],
      timeEvents: json['timeEvents'] != null 
          ? List<Map<String, dynamic>>.from(json['timeEvents'])
          : null,
      dayEvents: json['dayEvents'] != null 
          ? List<Map<String, dynamic>>.from(json['dayEvents'])
          : null,
      errors: json['errors'] != null 
          ? List<String>.from(json['errors'])
          : null,
    );
  }

  @override
  String toString() {
    return 'GoogleEventsImportResult(success: $success, imported: $importedCount, updated: $updatedCount, deleted: $deletedCount)';
  }
}