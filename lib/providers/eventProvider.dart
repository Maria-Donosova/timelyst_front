import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/eventsService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleEventsImportService.dart';
import 'package:timelyst_flutter/models/customApp.dart';

class EventProvider with ChangeNotifier {
  AuthService? _authService;
  GoogleEventsImportService? _googleEventsImportService;
  List<CustomAppointment> _events = [];
  
  // Track previous events for change detection
  List<CustomAppointment> _previousEvents = [];

  bool _isLoading = true;
  String _errorMessage = '';

  List<CustomAppointment> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  EventProvider({AuthService? authService, GoogleEventsImportService? googleEventsImportService}) 
    : _authService = authService,
      _googleEventsImportService = googleEventsImportService ?? GoogleEventsImportService();

  void setAuth(AuthService authService) {
    _authService = authService;
  }

  

  Future<void> fetchDayEvents() async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    final userId = await _authService!.getUserId();
    if (authToken == null || userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final dayEvents = await EventService.fetchDayEvents(userId, authToken);
      _updateEvents(dayEvents);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch day events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTimeEvents() async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    final userId = await _authService!.getUserId();
    if (authToken == null || userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final timeEvents = await EventService.fetchTimeEvents(userId, authToken);
      _updateEvents(timeEvents);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch time events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllEvents({bool forceFullRefresh = false}) async {
    final timestamp = DateTime.now().toIso8601String();
    print("🔄 [$timestamp] Entered fetchAllEvents in EventProvider (forceFullRefresh: $forceFullRefresh)");
    
    if (_authService == null) {
      print("AuthService is null in EventProvider");
      _isLoading = false;
      notifyListeners();
      return;
    }
    final authToken = await _authService!.getAuthToken();
    final userId = await _authService!.getUserId();
    final userEmail = await _authService!.getUserEmail();
    print('📧 [EventProvider] Retrieved user email: $userEmail');
    if (authToken == null || userId == null) {
      print("AuthToken or UserId is null in EventProvider");
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Only clear events on first load or forced refresh
      if (_events.isEmpty || forceFullRefresh) {
        print("🔄 [EventProvider] Performing full refresh (clearing existing events)");
        _events = [];
      } else {
        print("🔄 [EventProvider] Performing incremental sync (keeping existing events)");
      }

      // Fetch local events from backend
      final backendResults = await Future.wait([
        EventService.fetchDayEvents(userId, authToken),
        EventService.fetchTimeEvents(userId, authToken),
      ]);

      final dayEvents = backendResults[0];
      final timeEvents = backendResults[1];

      // Note: Google Calendar events are already imported by the backend during Google Sign-In
      // They appear in dayEvents and timeEvents with createdBy: GOOGLE
      // The issue is the backend is not preserving recurrence rules during import
      List<CustomAppointment> googleEvents = [];
      
      print('🔍 [EventProvider] Checking existing events for Google Calendar events...');
      final googleTimeEvents = timeEvents.where((event) => 
        event.userCalendars.contains('google') || 
        event.catTitle == 'imported' ||
        event.organizer.contains('google')).toList();
      final googleDayEvents = dayEvents.where((event) => 
        event.userCalendars.contains('google') || 
        event.catTitle == 'imported' ||
        event.organizer.contains('google')).toList();
        
      print('📊 [EventProvider] Found ${googleTimeEvents.length} Google time events and ${googleDayEvents.length} Google day events in backend data');
      
      // Check if any existing events have recurrence rules
      final recurringTimeEvents = timeEvents.where((event) => 
        event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty).toList();
      final recurringDayEvents = dayEvents.where((event) => 
        event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty).toList();
        
      print('📊 [EventProvider] Found ${recurringTimeEvents.length} recurring time events and ${recurringDayEvents.length} recurring day events');
      
      // Log all recurring events for debugging
      print('🔍 [EventProvider] All recurring time events:');
      for (final event in recurringTimeEvents) {
        print('  📅 Time: "${event.title}" - recurrenceRule: ${event.recurrenceRule}');
      }
      
      print('🔍 [EventProvider] All recurring day events:');
      for (final event in recurringDayEvents) {
        print('  📅 Day: "${event.title}" - recurrenceRule: ${event.recurrenceRule}');
      }
      
      // Check for any events created recently (within last hour)
      final recentEvents = [...timeEvents, ...dayEvents].where((event) {
        try {
          final eventTime = event.startTime;
          final now = DateTime.now();
          final oneHourAgo = now.subtract(Duration(hours: 1));
          return eventTime.isAfter(oneHourAgo) || eventTime.isAfter(now.subtract(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
      
      print('🕐 [EventProvider] Recent events (last 24 hours): ${recentEvents.length}');
      for (final event in recentEvents) {
        print('  ⏰ "${event.title}" at ${event.startTime} - recurring: ${event.recurrenceRule != null}');
      }

      // Perform incremental sync instead of replacing all events
      _syncEventsIncremental([...dayEvents, ...timeEvents, ...googleEvents]);

      // Debug: Check total events counts (createdBy info available in EventService logs)
      print('🔍 [EventProvider] === EVENT COUNT ANALYSIS ===');
      print('📊 [EventProvider] Day events count: ${dayEvents.length}');
      print('📊 [EventProvider] Time events count: ${timeEvents.length}');
      print('📊 [EventProvider] Check EventService logs above for source breakdown');

      print('📊 DEBUG: Fetched ${_events.length} total events at ${DateTime.now().toIso8601String()}');
      print('📊 DEBUG: - ${dayEvents.length} day events');
      print('📊 DEBUG: - ${timeEvents.length} time events');
      print('📊 DEBUG: - ${googleEvents.length} Google Calendar events');
      print('📊 DEBUG: User ID: $userId');
      print('📊 DEBUG: User Email: $userEmail');
      print('📊 DEBUG: Auth Token: ${authToken?.substring(0, 10)}...');
      
      // Log all event titles with IDs for debugging sync issues
      print('📋 [EventProvider] Current event details:');
      for (final event in _events) {
        final isRecurring = event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty;
        final isGoogle = event.userCalendars.contains('google') || event.catTitle == 'imported' || event.organizer.contains('google');
        print('  📅 ID: "${event.id}" | "${event.title}" | ${event.startTime} | ${isRecurring ? '[RECURRING]' : '[SINGLE]'} | ${isGoogle ? '[GOOGLE]' : '[LOCAL]'}');
      }
      
      // Track events that contain "Test Google recurring event" specifically
      final testEvents = _events.where((event) => 
        event.title.toLowerCase().contains('test google recurring') ||
        event.title.toLowerCase().contains('test recurring')
      ).toList();
      
      if (testEvents.isNotEmpty) {
        print('🔍 [EventProvider] Found ${testEvents.length} test recurring events:');
        for (final event in testEvents) {
          print('  🧪 "${event.title}" (${event.id}) - recurring: ${event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty}');
        }
      } else {
        print('⚠️ [EventProvider] No test recurring events found in current fetch');
      }
      
      // Compare with previous events to track changes
      if (_previousEvents.isNotEmpty) {
        final previousIds = _previousEvents.map((e) => e.id).toSet();
        final currentIds = _events.map((e) => e.id).toSet();
        
        final newEvents = _events.where((e) => !previousIds.contains(e.id)).toList();
        final removedEventIds = previousIds.where((id) => !currentIds.contains(id)).toList();
        
        if (newEvents.isNotEmpty) {
          print('🆕 [EventProvider] New events since last fetch:');
          for (final event in newEvents) {
            print('  ➕ "${event.title}" (${event.id})');
          }
        }
        
        if (removedEventIds.isNotEmpty) {
          print('🗑️ [EventProvider] Events removed since last fetch:');
          for (final id in removedEventIds) {
            final removedEvent = _previousEvents.firstWhere((e) => e.id == id);
            print('  ➖ "${removedEvent.title}" (${id})');
          }
        }
        
        if (newEvents.isEmpty && removedEventIds.isEmpty) {
          print('🔄 [EventProvider] No event changes detected since last fetch');
        }
      }
      
      // Store current events as previous for next comparison
      _previousEvents = List.from(_events);

      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch events: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomAppointment?> fetchEvent(String id, {bool isAllDay = false}) async {
    if (_authService == null) return null;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      CustomAppointment event;
      if (isAllDay) {
        event = await EventService.fetchTimeEvent(id, authToken);
      } else {
        event = await EventService.fetchTimeEvent(id, authToken);
      }
      _updateSingleEvent(event);
      _errorMessage = '';
      return event;
    } catch (e) {
      _errorMessage = 'Failed to fetch event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSingleEvent(CustomAppointment event) {
    _updateSingleEvent(event);
    notifyListeners();
  }

  Future<CustomAppointment?> createDayEvent(
      Map<String, dynamic> dayEventInput) async {
    if (_authService == null) return null;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final newEvent =
          await EventService.createDayEvent(dayEventInput, authToken);
      _events.add(newEvent);
      _errorMessage = '';
      notifyListeners();
      return newEvent;
    } catch (e) {
      _errorMessage = 'Failed to create day event: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomAppointment?> createTimeEvent(
      Map<String, dynamic> timeEventInput) async {
    if (_authService == null) return null;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final newEvent =
          await EventService.createTimeEvent(timeEventInput, authToken);
      _events.add(newEvent);
      _errorMessage = '';
      return newEvent;
    } catch (e) {
      _errorMessage = 'Failed to create time event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomAppointment?> updateDayEvent(
      String id, Map<String, dynamic> dayEventInput) async {
    if (_authService == null) return null;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedEvent =
          await EventService.updateDayEvent(id, dayEventInput, authToken);
      _updateSingleEvent(updatedEvent);
      _errorMessage = '';
      return updatedEvent;
    } catch (e) {
      _errorMessage = 'Failed to update day event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomAppointment?> updateTimeEvent(
      String id, Map<String, dynamic> timeEventInput) async {
    if (_authService == null) return null;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return null;

    if (id.isEmpty) {
      _errorMessage = 'Event ID cannot be empty';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final updatedEvent =
          await EventService.updateTimeEvent(id, timeEventInput, authToken);
      _updateSingleEvent(updatedEvent);
      _errorMessage = '';
      return updatedEvent;
    } catch (e) {
      _errorMessage = 'Failed to update time event: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDayEvent(String id) async {
    if (_authService == null) return false;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await EventService.deleteDayEvent(id, authToken);
      if (success) {
        _events.removeWhere((event) => event.id == id);
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete day event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTimeEvent(String id) async {
    if (_authService == null) return false;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await EventService.deleteTimeEvent(id, authToken);
      if (success) {
        _events.removeWhere((event) => event.id == id);
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete time event: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateEvents(List<CustomAppointment> newEvents) {
    final newEventIds = newEvents.map((e) => e.id).toSet();
    _events.removeWhere((event) => newEventIds.contains(event.id));
    _events.addAll(newEvents);
  }

  /// Performs incremental synchronization of events
  /// Only adds new events, updates changed events, and removes deleted events
  void _syncEventsIncremental(List<CustomAppointment> fetchedEvents) {
    final fetchedEventMap = Map<String, CustomAppointment>.fromIterable(
      fetchedEvents,
      key: (e) => e.id,
      value: (e) => e,
    );
    
    final currentEventMap = Map<String, CustomAppointment>.fromIterable(
      _events,
      key: (e) => e.id,
      value: (e) => e,
    );

    final fetchedIds = fetchedEventMap.keys.toSet();
    final currentIds = currentEventMap.keys.toSet();

    // Find new events (in fetched but not in current)
    final newEventIds = fetchedIds.difference(currentIds);
    final newEvents = newEventIds.map((id) => fetchedEventMap[id]!).toList();

    // Find removed events (in current but not in fetched)
    final removedEventIds = currentIds.difference(fetchedIds);

    // Find potentially updated events (in both)
    final commonEventIds = fetchedIds.intersection(currentIds);
    final updatedEvents = <CustomAppointment>[];
    
    for (final id in commonEventIds) {
      final currentEvent = currentEventMap[id]!;
      final fetchedEvent = fetchedEventMap[id]!;
      
      // Simple comparison - in a real app you might want to compare specific fields
      // or use a more sophisticated change detection mechanism
      if (_hasEventChanged(currentEvent, fetchedEvent)) {
        updatedEvents.add(fetchedEvent);
      }
    }

    // Apply changes
    int changes = 0;
    
    if (newEvents.isNotEmpty) {
      print('🆕 [EventProvider] Adding ${newEvents.length} new events:');
      for (final event in newEvents) {
        print('  ➕ "${event.title}" (${event.id})');
        _events.add(event);
        changes++;
      }
    }

    if (removedEventIds.isNotEmpty) {
      print('🗑️ [EventProvider] Removing ${removedEventIds.length} deleted events:');
      for (final id in removedEventIds) {
        final removedEvent = currentEventMap[id]!;
        print('  ➖ "${removedEvent.title}" (${id})');
        _events.removeWhere((event) => event.id == id);
        changes++;
      }
    }

    if (updatedEvents.isNotEmpty) {
      print('🔄 [EventProvider] Updating ${updatedEvents.length} changed events:');
      for (final updatedEvent in updatedEvents) {
        print('  🔄 "${updatedEvent.title}" (${updatedEvent.id})');
        final index = _events.indexWhere((event) => event.id == updatedEvent.id);
        if (index >= 0) {
          _events[index] = updatedEvent;
          changes++;
        }
      }
    }

    if (changes == 0) {
      print('✅ [EventProvider] No changes detected - events are up to date');
    } else {
      print('✅ [EventProvider] Applied $changes changes to event list');
    }
  }

  /// Simple event change detection
  /// In a real app, you might want to compare timestamps, content hashes, or specific fields
  bool _hasEventChanged(CustomAppointment current, CustomAppointment fetched) {
    return current.title != fetched.title ||
           current.startTime != fetched.startTime ||
           current.endTime != fetched.endTime ||
           current.recurrenceRule != fetched.recurrenceRule ||
           current.description != fetched.description ||
           current.location != fetched.location ||
           current.isAllDay != fetched.isAllDay;
  }

  void _updateSingleEvent(CustomAppointment updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index >= 0) {
      _events[index] = updatedEvent;
    } else {
      _events.add(updatedEvent);
    }
  }

  void addEvent(CustomAppointment event) {
    _events.add(event);
    notifyListeners();
  }

  /// Updates an existing event in the local state (for immediate UI response)
  /// This method is used for drag-and-drop operations and other local updates
  void updateEvent(CustomAppointment oldEvent, CustomAppointment newEvent) {
    final index = _events.indexWhere((event) => event.id == oldEvent.id);
    if (index >= 0) {
      _events[index] = newEvent;
      print('🔄 [EventProvider] Updated event ${newEvent.id} in local state');
      notifyListeners();
    } else {
      print('⚠️ [EventProvider] Event ${oldEvent.id} not found for update');
    }
  }

  /// Manually triggers Google Calendar import
  Future<void> importGoogleCalendarEvents() async {
    print('🔄 [EventProvider] importGoogleCalendarEvents() called directly');
    if (_authService == null || _googleEventsImportService == null) {
      print('⚠️ [EventProvider] Missing services: authService=${_authService != null}, googleEventsImportService=${_googleEventsImportService != null}');
      return;
    }
    
    final userId = await _authService!.getUserId();
    final userEmail = await _authService!.getUserEmail();
    print('🔍 [EventProvider] Direct import - userId: $userId, userEmail: $userEmail');
    
    if (userId == null || userEmail == null) {
      print('⚠️ [EventProvider] Cannot import Google events: missing user info');
      print('💡 [EventProvider] userId: $userId, userEmail: $userEmail');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔄 [EventProvider] Starting manual Google Calendar import');
      
      final googleEvents = await _googleEventsImportService!.getImportedEventsAsAppointments(
        userId: userId,
        email: userEmail,
      );

      // Remove existing Google events and add new ones
      _events.removeWhere((event) => event.userCalendars.contains('google'));
      _events.addAll(googleEvents);

      print('✅ [EventProvider] Imported ${googleEvents.length} Google Calendar events');
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to import Google Calendar events: $e';
      print('❌ [EventProvider] $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
