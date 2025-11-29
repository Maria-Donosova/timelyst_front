import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timelyst_flutter/models/calendars.dart';

import './../services/calendarsService.dart';
import './../services/authService.dart';
import './../services/googleIntegration/googleCalendarService.dart';
import './../utils/dateUtils.dart';

class CalendarProvider with ChangeNotifier {
  // State management
  List<Calendar> _calendars = [];
  Calendar? _primaryCalendar;
  bool _isLoading = false;
  String? _errorMessage;
  AuthService _authService;
  String? _userId;

  // Callback for triggering Google re-authentication
  Function()? _onGoogleAuthError;

  // Cache for calendar events
  final Map<String, List<CalendarEvent>> _eventsCache = {};
  final Map<String, DateTime> _lastEventFetchTime = {};

  CalendarProvider({
    required AuthService authService,
    Function()? onGoogleAuthError,
  })  : _authService = authService,
        _onGoogleAuthError = onGoogleAuthError;

  void setGoogleAuthErrorCallback(Function() callback) {
    _onGoogleAuthError = callback;
  }

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  // Getters
  List<Calendar> get calendars => List.unmodifiable(_calendars);
  Calendar? get primaryCalendar => _primaryCalendar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize with user ID
  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadInitialCalendars();
  }

  // Get events for a specific calendar
  List<CalendarEvent>? getEventsForCalendar(String calendarId) =>
      _eventsCache[calendarId];

  // Initial load
  Future<void> loadInitialCalendars() async {
    // Auto-initialize userId from AuthService if not set
    if (_userId == null) {
      _userId = await _authService.getUserId();
      if (_userId == null) {
        print('[CalendarProvider] Cannot load calendars: userId is null');
        return;
      }
      print('[CalendarProvider] Auto-initialized userId: $_userId');
    }
    _resetState();
    await _fetchCalendars();
    _identifyPrimaryCalendar();
  }

  // Refresh data
  Future<void> refreshCalendars() async {
    // Auto-initialize userId from AuthService if not set
    if (_userId == null) {
      _userId = await _authService.getUserId();
      if (_userId == null) {
        print('[CalendarProvider] Cannot refresh calendars: userId is null');
        return;
      }
      print('[CalendarProvider] Auto-initialized userId: $_userId');
    }
    _resetState();
    _eventsCache.clear();
    _lastEventFetchTime.clear();
    await _fetchCalendars(refresh: true);
    _identifyPrimaryCalendar();
  }

  // Fetch calendar events with caching
  Future<List<CalendarEvent>?> fetchCalendarEvents({
    required String calendarId,
    bool forceRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Check cache first
      final now = DateTime.now();
      final lastFetch = _lastEventFetchTime[calendarId];

      if (!forceRefresh &&
          lastFetch != null &&
          now.difference(lastFetch).inMinutes < 5 &&
          _eventsCache.containsKey(calendarId)) {
        return _eventsCache[calendarId];
      }

      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw Exception('User not authenticated');

      // For now, we'll use the events from the calendar model if available, or empty list
      // Since fetchUserCalendars might not return events anymore
      final calendar = _calendars.firstWhere((c) => c.id == calendarId);
      // Assuming events are fetched separately via EventService
      final events = <CalendarEvent>[]; 

      _eventsCache[calendarId] = events;
      _lastEventFetchTime[calendarId] = now;

      return events;
    } catch (e) {
      _errorMessage = 'Failed to fetch events: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD Operations
  Future<Calendar?> createCalendar(Map<String, dynamic> input) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw Exception('User not authenticated');

      final newCalendar = await CalendarsService.createCalendar(
        authToken: authToken,
        input: input,
      );

      _calendars.insert(0, newCalendar);
      if (newCalendar.isPrimary) _primaryCalendar = newCalendar;

      return newCalendar;
    } catch (e) {
      _errorMessage = 'Failed to create calendar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Calendar?> updateCalendar({
    required String calendarId,
    required Map<String, dynamic> input,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw Exception('User not authenticated');

      final updatedCalendar = await CalendarsService.updateCalendar(
        calendarId: calendarId,
        authToken: authToken,
        input: input,
      );

      _updateCalendarInState(updatedCalendar);
      return updatedCalendar;
    } catch (e) {
      _errorMessage = 'Failed to update calendar: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setCalendarSelection({
    required String calendarId,
    required bool isSelected,
  }) async {
    try {
      print('[CalendarProvider] setCalendarSelection called for $calendarId, isSelected=$isSelected');
      final calendar = getCalendarById(calendarId);
      if (calendar == null) {
        print('[CalendarProvider] ❌ Calendar $calendarId not found');
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      final input = {'isSelected': isSelected};

      final updatedCalendar = await CalendarsService.updateCalendar(
        calendarId: calendarId,
        authToken: authToken,
        input: input,
      );

      _updateCalendarInState(updatedCalendar);
      print('[CalendarProvider] ✅ Calendar updated successfully, new isSelected=${updatedCalendar.isSelected}');
      return true;
    } catch (e) {
      print('[CalendarProvider] ❌ Exception in setCalendarSelection: $e');
      _errorMessage = 'Failed to update calendar selection: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCalendar(String calendarId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw Exception('User not authenticated');

      await CalendarsService.deleteCalendar(
        calendarId: calendarId,
        authToken: authToken,
      );

      _calendars.removeWhere((calendar) => calendar.id == calendarId);
      _eventsCache.remove(calendarId);
      _lastEventFetchTime.remove(calendarId);

      if (_primaryCalendar?.id == calendarId) {
        _primaryCalendar = _calendars.firstWhereOrNull((c) => c.isPrimary);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete calendar: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  void _resetState() {
    _calendars = [];
    _errorMessage = null;
    _primaryCalendar = null;
    notifyListeners();
  }

  Future<void> _fetchCalendars({bool refresh = false}) async {
    try {
      _isLoading = true;
      if (refresh) notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw Exception('User not authenticated');

      final calendars = await CalendarsService.fetchUserCalendars(
        authToken: authToken,
      );

      if (refresh) {
        _calendars = calendars;
      } else {
        _calendars.addAll(calendars);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch calendars: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _identifyPrimaryCalendar() {
    _primaryCalendar = _calendars.firstWhereOrNull((c) => c.isPrimary);
  }

  void _updateCalendarInState(Calendar updatedCalendar) {
    final index = _calendars.indexWhere((c) => c.id == updatedCalendar.id);
    if (index >= 0) {
      _calendars[index] = updatedCalendar;
    } else {
      _calendars.add(updatedCalendar);
    }

    if (updatedCalendar.isPrimary) {
      _primaryCalendar = updatedCalendar;
    } else if (_primaryCalendar?.id == updatedCalendar.id) {
      _primaryCalendar = null;
    }
  }

  Calendar? getCalendarById(String calendarId) {
    try {
      return _calendars.firstWhere((calendar) => calendar.id == calendarId);
    } catch (e) {
      return null;
    }
  }

  List<Calendar> getSelectedCalendars() {
    return _calendars.where((calendar) => calendar.isSelected).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// Extension for firstWhereOrNull
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Placeholder for CalendarEvent model - replace with your actual implementation
class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      start: DateTimeUtils.parseAnyFormat(json['start']),
      end: DateTimeUtils.parseAnyFormat(json['end']),
    );
  }
}
