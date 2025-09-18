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

      // Also fetch Google Calendar events if user email is available
      List<CustomAppointment> googleEvents = [];
      if (userEmail != null && _googleEventsImportService != null) {
        try {
          print('🔍 [EventProvider] Importing Google Calendar events for: $userEmail');
          googleEvents = await _googleEventsImportService!.getImportedEventsAsAppointments(
            userId: userId,
            email: userEmail,
          );
          print('✅ [EventProvider] Imported ${googleEvents.length} Google Calendar events');
        } catch (e) {
          print('⚠️ [EventProvider] Google Calendar import failed: $e');
          // Don't fail the whole operation if Google import fails
        }
      }

      _events = [...dayEvents, ...timeEvents, ...googleEvents];

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
    if (_authService == null || _googleEventsImportService == null) return;
    
    final userId = await _authService!.getUserId();
    final userEmail = await _authService!.getUserEmail();
    
    if (userId == null || userEmail == null) {
      print('⚠️ [EventProvider] Cannot import Google events: missing user info');
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
