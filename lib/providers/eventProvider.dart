import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/eventsService.dart';
import 'package:timelyst_flutter/models/customApp.dart';

class EventProvider with ChangeNotifier {
  AuthService? _authService;
  List<CustomAppointment> _events = [];
  
  // Track previous events for change detection
  List<CustomAppointment> _previousEvents = [];

  bool _isLoading = false;
  String _errorMessage = '';
  
  // Cache management
  final Map<String, List<CustomAppointment>> _eventCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  List<CustomAppointment> get events => _events;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  EventProvider({AuthService? authService}) 
    : _authService = authService;

  void setAuth(AuthService authService) {
    _authService = authService;
  }

  /// Generate cache key based on date range
  String _generateCacheKey(DateTime startDate, DateTime endDate) {
    return '${startDate.toIso8601String().substring(0, 10)}_${endDate.toIso8601String().substring(0, 10)}';
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    final isValid = now.difference(timestamp) < _cacheValidDuration;
    
    if (!isValid) {
      print('🗄️ [EventProvider] Cache expired for key: $cacheKey');
      _eventCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    }
    
    return isValid;
  }

  /// Store events in cache
  void _cacheEvents(String cacheKey, List<CustomAppointment> events) {
    _eventCache[cacheKey] = List.from(events);
    _cacheTimestamps[cacheKey] = DateTime.now();
    print('🗄️ [EventProvider] Cached ${events.length} events for key: $cacheKey');
  }

  /// Get events from cache
  List<CustomAppointment>? _getCachedEvents(String cacheKey) {
    if (_isCacheValid(cacheKey)) {
      final cached = _eventCache[cacheKey];
      if (cached != null) {
        print('🗄️ [EventProvider] Retrieved ${cached.length} events from cache for key: $cacheKey');
        return List.from(cached);
      }
    }
    return null;
  }

  // Emergency reset for stuck loading state
  void forceResetLoadingState() {
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch events for day view (current day only)
  Future<void> fetchDayViewEvents({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return fetchAllEvents(
      startDate: startOfDay,
      endDate: endOfDay,
      viewType: 'day',
      forceFullRefresh: true,
    );
  }

  /// Fetch events for week view (current week)
  Future<void> fetchWeekViewEvents({DateTime? weekStart}) async {
    final targetDate = weekStart ?? DateTime.now();
    // Find the start of the week (Monday)
    final daysSinceMonday = (targetDate.weekday - 1) % 7;
    final startOfWeek = DateTime(targetDate.year, targetDate.month, targetDate.day).subtract(Duration(days: daysSinceMonday));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    
    return fetchAllEvents(
      startDate: startOfWeek,
      endDate: endOfWeek,
      viewType: 'week',
      forceFullRefresh: true,
    );
  }

  /// Fetch events for month view (current month)
  Future<void> fetchMonthViewEvents({DateTime? month}) async {
    final targetDate = month ?? DateTime.now();
    final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
    final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 0).add(Duration(days: 1));
    
    return fetchAllEvents(
      startDate: startOfMonth,
      endDate: endOfMonth,
      viewType: 'month',
      forceFullRefresh: true,
    );
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

  Future<void> fetchAllEvents({
    bool forceFullRefresh = false,
    DateTime? startDate,
    DateTime? endDate,
    String? viewType,
  }) async {
    final startTime = DateTime.now();
    final viewTypeStr = viewType ?? 'default';
    print('⏱️ [EventProvider] Starting fetchAllEvents at ${startTime} for view: $viewTypeStr');
    
    if (startDate != null && endDate != null) {
      print('📅 [EventProvider] Using custom date range: ${startDate.toIso8601String().substring(0, 10)} to ${endDate.toIso8601String().substring(0, 10)}');
      
      // Check cache first (unless forcing refresh)
      if (!forceFullRefresh) {
        final cacheKey = _generateCacheKey(startDate, endDate);
        final cachedEvents = _getCachedEvents(cacheKey);
        if (cachedEvents != null) {
          _events = cachedEvents;
          _previousEvents = List.from(_events);
          notifyListeners();
          print('⚡ [EventProvider] Returned cached events, skipping API call');
          return;
        }
      }
    }
    
    // Prevent concurrent fetches (but allow forced refresh)
    if (_isLoading && !forceFullRefresh) {
      print('⚠️ [EventProvider] Already loading, skipping fetch');
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
        _events = [];
      }
      
      print('🔄 [EventProvider] Starting backend API calls...');
      final apiStartTime = DateTime.now();
      
      final backendResults = await Future.wait([
        EventService.fetchDayEvents(userId, authToken, startDate: startDate, endDate: endDate),
        EventService.fetchTimeEvents(userId, authToken, startDate: startDate, endDate: endDate),
      ]).timeout(Duration(seconds: 30));
      
      final apiEndTime = DateTime.now();
      final apiDuration = apiEndTime.difference(apiStartTime);
      print('🔄 [EventProvider] Backend API calls completed in ${apiDuration.inMilliseconds}ms');

      final dayEvents = backendResults[0];
      final timeEvents = backendResults[1];

      print('🔍 [EventProvider] Fetched ${dayEvents.length} day events and ${timeEvents.length} time events');
      
      // Debug: Log events by source and time
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(Duration(days: 1));
      final tomorrowEnd = todayStart.add(Duration(days: 2));
      
      final allEvents = [...dayEvents, ...timeEvents];
      final todayEvents = allEvents.where((event) {
        return event.startTime.isAfter(todayStart) && event.startTime.isBefore(todayEnd);
      }).toList();
      
      final tomorrowEvents = allEvents.where((event) {
        return event.startTime.isAfter(todayEnd) && event.startTime.isBefore(tomorrowEnd);
      }).toList();
      
      print('📅 [EventProvider] Today\'s events (${todayEvents.length}):');
      for (int i = 0; i < todayEvents.length; i++) {
        final event = todayEvents[i];
        final timeStr = event.isAllDay ? 'All Day' : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
        print('  [$i] $timeStr - "${event.title}" (source: ${event.userCalendars}, id: ${event.id})');
      }
      
      print('📅 [EventProvider] Tomorrow\'s events (${tomorrowEvents.length}):');
      for (int i = 0; i < tomorrowEvents.length; i++) {
        final event = tomorrowEvents[i];
        final timeStr = event.isAllDay ? 'All Day' : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
        print('  [$i] $timeStr - "${event.title}" (source: ${event.userCalendars}, id: ${event.id})');
      }
      
      // Also check for events with missing Google Calendar identifiers
      final googleEvents = allEvents.where((event) => 
        event.userCalendars.any((cal) => cal.toLowerCase().contains('google')) ||
        event.organizer.toLowerCase().contains('google') ||
        event.catTitle == 'imported'
      ).toList();
      
      print('📅 [EventProvider] Google Calendar events (${googleEvents.length}):');
      for (int i = 0; i < googleEvents.length; i++) {
        final event = googleEvents[i];
        final timeStr = event.isAllDay ? 'All Day' : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
        print('  [$i] ${event.startTime.toIso8601String().substring(0, 10)} $timeStr - "${event.title}" (${event.userCalendars})');
      }

      // Directly sync all events from backend (no filtering/re-merging needed)
      _syncEventsIncremental(allEvents);

      // Store current events as previous for next comparison
      _previousEvents = List.from(_events);

      // Cache the results if we have a specific date range
      if (startDate != null && endDate != null) {
        final cacheKey = _generateCacheKey(startDate, endDate);
        _cacheEvents(cacheKey, allEvents);
      }

      _errorMessage = '';
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('⏱️ [EventProvider] fetchAllEvents completed in ${duration.inMilliseconds}ms');
      
    } catch (e) {
      _errorMessage = 'Failed to fetch events: $e';
      print('❌ [EventProvider] Error: $_errorMessage');
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('⏱️ [EventProvider] fetchAllEvents failed after ${duration.inMilliseconds}ms');
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
    final syncStartTime = DateTime.now();
    print('🔄 [EventProvider] Starting incremental sync of ${fetchedEvents.length} fetched events with ${_events.length} existing events');
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

    final syncEndTime = DateTime.now();
    final syncDuration = syncEndTime.difference(syncStartTime);
    print('🔄 [EventProvider] Incremental sync completed: $changes changes made in ${syncDuration.inMilliseconds}ms');
    
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
      notifyListeners();
    } else {
    }
  }

}
