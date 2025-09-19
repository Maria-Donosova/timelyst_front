import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/eventsService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleEventsImportService.dart';
import 'package:timelyst_flutter/models/customApp.dart';

class EventProvider with ChangeNotifier {
  AuthService? _authService;
  GoogleEventsImportService? _googleEventsImportService;
  List<CustomAppointment> _events = [];

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

  Future<void> fetchAllEvents() async {
    print("Entered fetchAllEvents in EventProvider");
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
      _events = [];

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
      
      // Log the "Test Recurrent" event specifically
      final testRecurrentEvent = timeEvents.where((event) => 
        event.title.toLowerCase().contains('recurrent')).toList();
      for (final event in testRecurrentEvent) {
        print('🎯 [EventProvider] Test Recurrent Event: "${event.title}" - recurrenceRule: ${event.recurrenceRule}');
      }

      // TEMPORARY: Add a test recurring event to verify Syncfusion works
      final testRecurringEvent = CustomAppointment(
        id: 'test-recurring-123',
        title: 'TEST: Weekly Recurring Event',
        description: 'Test event to verify Syncfusion recurring events work',
        startTime: DateTime.now().add(Duration(hours: 1)),
        endTime: DateTime.now().add(Duration(hours: 2)),
        isAllDay: false,
        location: 'Test Location',
        organizer: 'Test Organizer',
        recurrenceRule: 'RRULE:FREQ=WEEKLY;BYDAY=TH;COUNT=10', // Every Thursday for 10 weeks
        catTitle: 'test',
        participants: 'test@example.com',
        recurrenceExceptionDates: null,
        userCalendars: ['test'],
        timeEventInstance: null,
        catColor: Colors.blue,
      );

      _events = [...dayEvents, ...timeEvents, ...googleEvents, testRecurringEvent];

      print('📊 DEBUG: Fetched ${_events.length} total events');
      print('📊 DEBUG: - ${dayEvents.length} day events');
      print('📊 DEBUG: - ${timeEvents.length} time events');
      print('📊 DEBUG: - ${googleEvents.length} Google Calendar events');
      print('📊 DEBUG: User ID: $userId');
      print('📊 DEBUG: User Email: $userEmail');
      print('📊 DEBUG: Auth Token: ${authToken?.substring(0, 10)}...');

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
