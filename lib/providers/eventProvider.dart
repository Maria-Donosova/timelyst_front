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

  bool _isLoading = false;
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

  // Emergency reset for stuck loading state
  void forceResetLoadingState() {
    print("🔧 [EventProvider] Force resetting loading state");
    _isLoading = false;
    notifyListeners();
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
    print("🔄 [EventProvider] Fetching events (forceFullRefresh: $forceFullRefresh)");
    
    // Prevent concurrent fetches (but allow forced refresh)
    if (_isLoading && !forceFullRefresh) {
      print("⚠️ [EventProvider] Already loading, skipping concurrent fetch (use forceFullRefresh to override)");
      return;
    }
    
    if (_authService == null) {
      print("AuthService is null in EventProvider");
      _isLoading = false;
      notifyListeners();
      return;
    }
    final authToken = await _authService!.getAuthToken();
    final userId = await _authService!.getUserId();
    final userEmail = await _authService!.getUserEmail();
    if (authToken == null || userId == null) {
      print("❌ [EventProvider] Missing authentication credentials");
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
      }
      
      final backendResults = await Future.wait([
        EventService.fetchDayEvents(userId, authToken),
        EventService.fetchTimeEvents(userId, authToken),
      ]).timeout(Duration(seconds: 30));

      final dayEvents = backendResults[0];
      final timeEvents = backendResults[1];

      // Filter Google events for compatibility
      List<CustomAppointment> googleEvents = [];
      try {
        final googleTimeEvents = timeEvents.where((event) => 
          event.userCalendars.contains('google') || 
          event.catTitle == 'imported' ||
          (event.organizer.isNotEmpty && event.organizer.contains('google'))
        ).toList();
        
        final googleDayEvents = dayEvents.where((event) => 
          event.userCalendars.contains('google') || 
          event.catTitle == 'imported' ||
          (event.organizer.isNotEmpty && event.organizer.contains('google'))
        ).toList();
        
        googleEvents = [...googleTimeEvents, ...googleDayEvents];
      } catch (e) {
        print('❌ [EventProvider] Error filtering Google events: $e');
        googleEvents = [];
      }
      
      // Sync events
      _syncEventsIncremental([...dayEvents, ...timeEvents, ...googleEvents]);
      
      print('✅ [EventProvider] Synced ${_events.length} total events');

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
      for (final event in newEvents) {
        _events.add(event);
        changes++;
      }
    }

    if (removedEventIds.isNotEmpty) {
      for (final id in removedEventIds) {
        _events.removeWhere((event) => event.id == id);
        changes++;
      }
    }

    if (updatedEvents.isNotEmpty) {
      for (final updatedEvent in updatedEvents) {
        final index = _events.indexWhere((event) => event.id == updatedEvent.id);
        if (index >= 0) {
          _events[index] = updatedEvent;
          changes++;
        }
      }
    }

    if (changes > 0) {
      notifyListeners();
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
