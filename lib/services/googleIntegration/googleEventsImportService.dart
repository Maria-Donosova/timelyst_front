import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Sync token storage for incremental sync
  String? _currentSyncToken;
  DateTime? _lastSyncTime;
  
  static const String _syncTokenKey = 'google_events_sync_token';
  static const String _lastSyncTimeKey = 'google_events_last_sync_time';

  /// Loads sync token and last sync time from secure storage
  Future<void> _loadSyncState() async {
    try {
      _currentSyncToken = await _storage.read(key: _syncTokenKey);
      final lastSyncTimeString = await _storage.read(key: _lastSyncTimeKey);
      if (lastSyncTimeString != null) {
        _lastSyncTime = DateTime.parse(lastSyncTimeString);
      }
      print('🔍 [GoogleEventsImportService] Loaded sync state - token: ${_currentSyncToken != null ? '${_currentSyncToken!.substring(0, 10)}...' : 'null'}, lastSync: $_lastSyncTime');
    } catch (e) {
      print('⚠️ [GoogleEventsImportService] Error loading sync state: $e');
    }
  }

  /// Saves sync token and last sync time to secure storage
  Future<void> _saveSyncState() async {
    try {
      if (_currentSyncToken != null) {
        await _storage.write(key: _syncTokenKey, value: _currentSyncToken);
      }
      if (_lastSyncTime != null) {
        await _storage.write(key: _lastSyncTimeKey, value: _lastSyncTime!.toIso8601String());
      }
      print('✅ [GoogleEventsImportService] Saved sync state');
    } catch (e) {
      print('⚠️ [GoogleEventsImportService] Error saving sync state: $e');
    }
  }

  /// Clears sync state (forces full sync next time)
  Future<void> _clearSyncState() async {
    try {
      await _storage.delete(key: _syncTokenKey);
      await _storage.delete(key: _lastSyncTimeKey);
      _currentSyncToken = null;
      _lastSyncTime = null;
      print('🔄 [GoogleEventsImportService] Cleared sync state');
    } catch (e) {
      print('⚠️ [GoogleEventsImportService] Error clearing sync state: $e');
    }
  }

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

      // Set default time range if not provided (import last 3 months + next 6 months for better performance)
      timeMin ??= DateTime.now().subtract(const Duration(days: 90));
      timeMax ??= DateTime.now().add(const Duration(days: 180));

      final requestBody = {
        'userId': userId,
        'email': email,
        'syncToken': syncToken,
        'timeMin': timeMin.toIso8601String(),
        'timeMax': timeMax.toIso8601String(),
        'includeRecurring': true, // Important for recurring events
        'expandRecurring': false,  // Keep recurring events as rules instead of expanding into instances
      };

      print('🔍 [GoogleEventsImportService] Sending request with body: $requestBody');

      final response = await _apiClient.post(
        '${Config.backendURL}/google/events/import',
        body: requestBody,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [GoogleEventsImportService] Import successful');
        print('🔍 [GoogleEventsImportService] Response keys: ${data.keys.toList()}');
        print('🔍 [GoogleEventsImportService] Full response: $data');
        
        // Debug recurring events in raw response
        if (data['timeEvents'] != null) {
          final timeEvents = data['timeEvents'] as List;
          final recurringTimeEvents = timeEvents.where((event) => 
            event['recurrenceRule'] != null && event['recurrenceRule'].toString().isNotEmpty).toList();
          print('🔄 [GoogleEventsImportService] Found ${recurringTimeEvents.length} recurring time events in backend response');
          for (final event in recurringTimeEvents) {
            print('  - Time Event: "${event['event_title']}" has recurrenceRule: ${event['recurrenceRule']}');
          }
        }
        
        if (data['dayEvents'] != null) {
          final dayEvents = data['dayEvents'] as List;
          final recurringDayEvents = dayEvents.where((event) => 
            event['recurrenceRule'] != null && event['recurrenceRule'].toString().isNotEmpty).toList();
          print('🔄 [GoogleEventsImportService] Found ${recurringDayEvents.length} recurring day events in backend response');
          for (final event in recurringDayEvents) {
            print('  - Day Event: "${event['event_title']}" has recurrenceRule: ${event['recurrenceRule']}');
          }
        }
        
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
          'expandRecurring': false,
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
          'expandRecurring': false,
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

  /// Smart sync method that uses incremental sync when possible
  Future<List<CustomAppointment>> getImportedEventsAsAppointments({
    required String userId,
    required String email,
    bool forceFullSync = false,
  }) async {
    print('🔄 [GoogleEventsImportService] Starting smart sync for events');
    
    try {
      // Load sync state from storage first
      await _loadSyncState();
      
      GoogleEventsImportResult importResult;
      
      // Determine if we should do incremental sync or full sync
      final shouldDoIncrementalSync = !forceFullSync && 
          _currentSyncToken != null && 
          _lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!).inMinutes < 5; // Sync within last 5 minutes
          
      if (shouldDoIncrementalSync) {
        print('🔄 [GoogleEventsImportService] Performing incremental sync with token: ${_currentSyncToken!.substring(0, 10)}...');
        try {
          importResult = await syncCalendarEvents(
            userId: userId,
            email: email,
            syncToken: _currentSyncToken!,
          );
          
          // Update sync token and time
          if (importResult.nextSyncToken != null) {
            _currentSyncToken = importResult.nextSyncToken;
            _lastSyncTime = DateTime.now();
            await _saveSyncState();
          }
          
        } catch (e) {
          print('⚠️ [GoogleEventsImportService] Incremental sync failed, falling back to full sync: $e');
          // Fall back to full sync if incremental fails
          importResult = await _performFullSync(userId, email);
        }
      } else {
        print('🔄 [GoogleEventsImportService] Performing full sync (reason: ${forceFullSync ? 'forced' : 'no valid sync token or stale'})');
        importResult = await _performFullSync(userId, email);
      }

      return _convertImportResultToAppointments(importResult);
      
    } catch (e) {
      print('❌ [GoogleEventsImportService] Error in smart sync: $e');
      rethrow;
    }
  }

  /// Performs a full sync and updates tokens
  Future<GoogleEventsImportResult> _performFullSync(String userId, String email) async {
    final result = await importAllCalendarEvents(
      userId: userId,
      email: email,
    );
    
    // Store sync token for future incremental syncs
    if (result.nextSyncToken != null) {
      _currentSyncToken = result.nextSyncToken;
      _lastSyncTime = DateTime.now();
      await _saveSyncState();
      print('✅ [GoogleEventsImportService] Stored sync token for future incremental syncs');
    }
    
    return result;
  }

  /// Converts import result to CustomAppointments
  List<CustomAppointment> _convertImportResultToAppointments(GoogleEventsImportResult importResult) {
    final appointments = <CustomAppointment>[];
    
    print('🔍 [GoogleEventsImportService] Converting import result - timeEvents: ${importResult.timeEvents?.length ?? 0}, dayEvents: ${importResult.dayEvents?.length ?? 0}');
    
    // Convert imported time events to appointments
    if (importResult.timeEvents != null) {
      for (final timeEventData in importResult.timeEvents!) {
        try {
          final timeEvent = TimeEvent.fromJson(timeEventData);
          final appointment = EventMapper.mapTimeEventToCustomAppointment(timeEvent);
          
          // Log recurring events specifically
          if (appointment.recurrenceRule != null && appointment.recurrenceRule!.isNotEmpty) {
            print('🔄 [GoogleEventsImportService] Found recurring time event: "${appointment.title}" with rule: ${appointment.recurrenceRule}');
          }
          
          appointments.add(appointment);
        } catch (e) {
          print('⚠️ [GoogleEventsImportService] Error mapping time event: $e');
          print('⚠️ [GoogleEventsImportService] TimeEvent data: $timeEventData');
        }
      }
    }

    // Convert imported day events to appointments
    if (importResult.dayEvents != null) {
      for (final dayEventData in importResult.dayEvents!) {
        try {
          final dayEvent = DayEvent.fromJson(dayEventData);
          final appointment = EventMapper.mapDayEventToCustomAppointment(dayEvent);
          
          // Log recurring events specifically
          if (appointment.recurrenceRule != null && appointment.recurrenceRule!.isNotEmpty) {
            print('🔄 [GoogleEventsImportService] Found recurring day event: "${appointment.title}" with rule: ${appointment.recurrenceRule}');
          }
          
          appointments.add(appointment);
        } catch (e) {
          print('⚠️ [GoogleEventsImportService] Error mapping day event: $e');
          print('⚠️ [GoogleEventsImportService] DayEvent data: $dayEventData');
        }
      }
    }

    final recurringCount = appointments.where((a) => a.recurrenceRule != null && a.recurrenceRule!.isNotEmpty).length;
    print('✅ [GoogleEventsImportService] Mapped ${appointments.length} events to appointments (${recurringCount} recurring)');
    return appointments;
  }
  
  /// Forces a full sync (useful for manual refresh)
  Future<void> forceFullSync(String userId, String email) async {
    print('🔄 [GoogleEventsImportService] Forcing full sync...');
    await _clearSyncState();
    await getImportedEventsAsAppointments(
      userId: userId, 
      email: email, 
      forceFullSync: true
    );
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