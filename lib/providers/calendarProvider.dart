import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timelyst_flutter/models/calendars.dart';

import './../services/calendarsService.dart';
import './../services/authService.dart';

class CalendarProvider with ChangeNotifier {
  // State management
  List<Calendar> _calendars = [];
  Calendar? _primaryCalendar;
  bool _isLoading = false;
  String? _errorMessage;
  int _totalCount = 0;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _pageSize = 20;
  AuthService _authService;
  String? _userId;

  // Cache for calendar events
  final Map<String, List<CalendarEvent>> _eventsCache = {};
  final Map<String, DateTime> _lastEventFetchTime = {};

  CalendarProvider({required AuthService authService})
      : _authService = authService;

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  // Getters
  List<Calendar> get calendars => List.unmodifiable(_calendars);
  Calendar? get primaryCalendar => _primaryCalendar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;

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
    if (_userId == null) return;
    _resetState();
    await _fetchCalendars();
    _identifyPrimaryCalendar();
  }

  // Pagination support
  Future<void> loadMoreCalendars() async {
    if (_userId == null || !_hasMore || _isLoading) return;
    _currentOffset += _pageSize;
    await _fetchCalendars();
  }

  // Refresh data
  Future<void> refreshCalendars() async {
    if (_userId == null) return;
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
        throw CalendarServiceException('User not authenticated');

      // Here you would call your event fetching service
      // This is a placeholder - implement according to your actual event service
      // final events = await CalendarEventsService.fetchEvents(
      //   calendarId: calendarId,
      //   authToken: authToken,
      //   startDate: startDate,
      //   endDate: endDate,
      // );

      // For now, we'll use the events from the calendar model
      final calendar = _calendars.firstWhere((c) => c.id == calendarId);
      final events = calendar.eventCount
          .map((e) => CalendarEvent.fromJson(jsonDecode(e)))
          .toList();

      _eventsCache[calendarId] = events;
      _lastEventFetchTime[calendarId] = now;

      return events;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to fetch events: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD Operations
  Future<Calendar?> createCalendar(CalendarInput input) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw CalendarServiceException('User not authenticated');

      final newCalendar = await CalendarsService.createCalendar(
        authToken: authToken,
        input: input,
      );

      _calendars.insert(0, newCalendar);
      if (newCalendar.isPrimary) _primaryCalendar = newCalendar;

      return newCalendar;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
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
    required CalendarInput input,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw CalendarServiceException('User not authenticated');

      final updatedCalendar = await CalendarsService.updateCalendar(
        calendarId: calendarId,
        authToken: authToken,
        input: input,
      );

      _updateCalendarInState(updatedCalendar);
      return updatedCalendar;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return null;
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
      final calendar = getCalendarById(calendarId);
      if (calendar == null) return false;

      // Create a new input with just the selection change
      final input = CalendarInput(
        title: calendar.metadata.title,
        timeZone: calendar.metadata.timeZone ?? 'UTC',
        isPrimary: calendar.isPrimary,
        source: calendar.source.name,
        color: '#${calendar.metadata.color.toARGB32().toRadixString(16)}',
        description: calendar.metadata.description,
      );

      final updatedCalendar = await updateCalendar(
        calendarId: calendarId,
        input: input,
      );

      return updatedCalendar != null;
    } catch (e) {
      _errorMessage = 'Failed to update calendar selection: ${e.toString()}';
      return false;
    }
  }

  Future<bool> deleteCalendar(String calendarId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final authToken = await _authService.getAuthToken();
      if (authToken == null)
        throw CalendarServiceException('User not authenticated');

      final success = await CalendarsService.deleteCalendar(
        calendarId: calendarId,
        authToken: authToken,
      );

      if (success) {
        _calendars.removeWhere((calendar) => calendar.id == calendarId);
        _eventsCache.remove(calendarId);
        _lastEventFetchTime.remove(calendarId);

        if (_primaryCalendar?.id == calendarId) {
          _primaryCalendar = _calendars.firstWhereOrNull((c) => c.isPrimary);
        }
      }

      return success;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      return false;
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
    _currentOffset = 0;
    _hasMore = true;
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
        throw CalendarServiceException('User not authenticated');

      final result = await CalendarsService.fetchUserCalendars(
        userId: _userId!, // Now passing the user ID
        authToken: authToken,
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (refresh) {
        _calendars = result.calendars;
      } else {
        _calendars.addAll(result.calendars);
      }

      _totalCount = result.totalCount;
      _hasMore = result.hasMore;
      _errorMessage = null;
    } on CalendarServiceException catch (e) {
      _errorMessage = e.message;
      if (e.statusCode == 401) {
        // Handle unauthorized error (e.g., trigger logout)
      }
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
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}
