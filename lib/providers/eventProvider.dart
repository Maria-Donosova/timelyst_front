import 'dart:async';
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
  static const Duration _cacheValidDuration = Duration(minutes: 1);
  
  // Debug flag - set to true temporarily for debugging API issues
  static const bool _debugLogging = true;
  
  // Timeout configurations for different scenarios
  static const Duration _defaultEventTimeout = Duration(seconds: 60); // Longer timeout for CalDAV operations
  static const Duration _parallelEventTimeout = Duration(seconds: 45); // Still reasonable timeout when loading with tasks

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
      if (_debugLogging) print('🗄️ [EventProvider] Cache expired for key: $cacheKey');
      _eventCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    }
    
    return isValid;
  }

  /// Store events in cache
  void _cacheEvents(String cacheKey, List<CustomAppointment> events) {
    _eventCache[cacheKey] = List.from(events);
    _cacheTimestamps[cacheKey] = DateTime.now();
    if (_debugLogging) print('🗄️ [EventProvider] Cached ${events.length} events for key: $cacheKey');
  }

  /// Get events from cache
  List<CustomAppointment>? _getCachedEvents(String cacheKey) {
    if (_isCacheValid(cacheKey)) {
      final cached = _eventCache[cacheKey];
      if (cached != null) {
        if (_debugLogging) print('🗄️ [EventProvider] Retrieved ${cached.length} events from cache for key: $cacheKey');
        return List.from(cached);
      }
    }
    return null;
  }

  /// Clear all cached events and force fresh fetch on next request
  void invalidateCache() {
    _eventCache.clear();
    _cacheTimestamps.clear();
    if (_debugLogging) print('🗄️ [EventProvider] Cache invalidated - forcing fresh fetch on next request');
  }

  /// Clear expired cache entries (for cleanup)
  void _clearExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheValidDuration) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _eventCache.remove(key);
      _cacheTimestamps.remove(key);
      if (_debugLogging) print('🗄️ [EventProvider] Removed expired cache entry: $key');
    }
  }

  // Emergency reset for stuck loading state
  void forceResetLoadingState() {
    _isLoading = false;
    notifyListeners();
  }


  /// Fetch events for day view (current day only)
  Future<void> fetchDayViewEvents({DateTime? date, bool isParallelLoad = false}) async {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return fetchAllEvents(
      startDate: startOfDay,
      endDate: endOfDay,
      viewType: isParallelLoad ? 'parallel' : 'day',
      forceFullRefresh: false, // Don't replace all events, sync instead
    );
  }

  /// Fetch events for week view (current week)
  Future<void> fetchWeekViewEvents({DateTime? weekStart}) async {
    final startOfWeek = weekStart ?? DateTime.now();
    // weekStart is already the start of the visible week from the calendar
    // Just add 7 days to get the end of the week
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    
    return fetchAllEvents(
      startDate: startOfWeek,
      endDate: endOfWeek,
      viewType: 'week',
      forceFullRefresh: false, // Don't replace all events, sync instead
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
      forceFullRefresh: false, // Don't replace all events, sync instead
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
    Duration? customTimeout,
  }) async {
    final startTime = DateTime.now();
    final viewTypeStr = viewType ?? 'default';
    if (_debugLogging) print('⏱️ [EventProvider] Starting fetchAllEvents at ${startTime} for view: $viewTypeStr');
    
    if (startDate != null && endDate != null) {
      if (_debugLogging) print('📅 [EventProvider] Using custom date range: ${startDate.toIso8601String().substring(0, 10)} to ${endDate.toIso8601String().substring(0, 10)}');
      
      // Check cache first (unless forcing refresh)
      if (!forceFullRefresh) {
        final cacheKey = _generateCacheKey(startDate, endDate);
        final cachedEvents = _getCachedEvents(cacheKey);
        if (cachedEvents != null) {
          _events = cachedEvents;
          _previousEvents = List.from(_events);
          notifyListeners();
          if (_debugLogging) print('⚡ [EventProvider] Returned cached events, skipping API call');
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
      final msg = "❌ [EventProvider] Missing authentication - Token: ${authToken != null ? 'Present' : 'NULL'}, UserId: ${userId != null ? 'Present' : 'NULL'}";
      print(msg);
      _errorMessage = 'Authentication required. Please log in again.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    print("✅ [EventProvider] Auth credentials valid - UserID: ${userId.length > 10 ? '${userId.substring(0, 10)}...' : userId}");

    _isLoading = true;
    notifyListeners();

    try {
      // Only clear events on first load or forced refresh
      if (_events.isEmpty || forceFullRefresh) {
        _events = [];
      }
      
      print('🔄 [EventProvider] Starting backend API calls...');
      print('🔄 [EventProvider] Fetching events for date range: ${startDate?.toIso8601String().substring(0, 10)} to ${endDate?.toIso8601String().substring(0, 10)}');
      final apiStartTime = DateTime.now();
      
      // Choose timeout based on context
      final timeout = customTimeout ?? 
                     (viewType == 'parallel' ? _parallelEventTimeout : _defaultEventTimeout);
      
      final backendResults = await Future.wait([
        EventService.fetchDayEvents(userId, authToken, startDate: startDate, endDate: endDate),
        EventService.fetchTimeEvents(userId, authToken, startDate: startDate, endDate: endDate),
      ]).timeout(
        timeout,
        onTimeout: () {
          print('⏰ [EventProvider] API calls timed out after ${timeout.inSeconds} seconds');
          throw TimeoutException('Event fetching timed out', timeout);
        }
      );
      
      final apiEndTime = DateTime.now();
      final apiDuration = apiEndTime.difference(apiStartTime);
      print('✅ [EventProvider] Backend API calls completed in ${apiDuration.inMilliseconds}ms');

      final dayEvents = backendResults[0];
      final timeEvents = backendResults[1];

      if (_debugLogging) {
        print('🔍 [EventProvider] Fetched ${dayEvents.length} day events and ${timeEvents.length} time events');
        
        // Debug: Log events by source and time
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(Duration(days: 1));
        
        final allEvents = [...dayEvents, ...timeEvents];
        final todayEvents = allEvents.where((event) {
          return event.startTime.isAfter(todayStart) && event.startTime.isBefore(todayEnd);
        }).toList();
        
        print('📅 [EventProvider] Today\'s events (${todayEvents.length}):');
        for (int i = 0; i < todayEvents.length && i < 5; i++) { // Limit to first 5 for brevity
          final event = todayEvents[i];
          final timeStr = event.isAllDay ? 'All Day' : '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
          print('  [$i] $timeStr - "${event.title}" (source: ${event.userCalendars})');
        }
        if (todayEvents.length > 5) {
          print('  ... and ${todayEvents.length - 5} more');
        }
      }
      
      final allEvents = [...dayEvents, ...timeEvents];

      // Sync events for the specific date range requested
      if (startDate != null && endDate != null) {
        _syncEventsForDateRange(allEvents, startDate, endDate);
      } else {
        // For backward compatibility, replace all events if no date range specified
        _syncEventsIncremental(allEvents);
      }

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
      print('✅ [EventProvider] Loaded ${_events.length} events in ${duration.inMilliseconds}ms ($viewTypeStr)');
      
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

  /// Syncs events for a specific date range without affecting events outside that range
  void _syncEventsForDateRange(List<CustomAppointment> fetchedEvents, DateTime startDate, DateTime endDate) {
    final syncStartTime = DateTime.now();
    if (_debugLogging) print('🔄 [EventProvider] Starting date range sync for ${startDate.toIso8601String().substring(0, 10)} to ${endDate.toIso8601String().substring(0, 10)}');
    
    // Create a buffer to prevent boundary issues - extend range by 1 day on each side
    final bufferStart = startDate.subtract(Duration(days: 1));
    final bufferEnd = endDate.add(Duration(days: 1));
    
    // Only remove events that are completely outside the buffered range AND being replaced
    final fetchedEventIds = fetchedEvents.map((e) => e.id).toSet();
    final eventsToKeep = _events.where((event) {
      // Keep events outside the core range (not the buffer)
      final outsideCoreRange = event.startTime.isBefore(startDate) || 
                              event.startTime.isAfter(endDate) ||
                              event.startTime.isAtSameMomentAs(endDate);
      
      // Keep events that aren't being replaced by new data
      final notBeingReplaced = !fetchedEventIds.contains(event.id);
      
      // For all-day events, be more lenient with date boundaries
      final isAllDayWithinBuffer = event.isAllDay && 
                                  event.startTime.isAfter(bufferStart) && 
                                  event.startTime.isBefore(bufferEnd);
      
      final shouldKeep = outsideCoreRange || notBeingReplaced || isAllDayWithinBuffer;
      
      if (_debugLogging && !shouldKeep) {
        print('🗑️ [EventProvider] Removing/replacing: "${event.title}" (${event.startTime.toIso8601String().substring(0, 10)})');
      }
      
      return shouldKeep;
    }).toList();
    
    // Add all fetched events (they will replace any with same ID)
    final updatedEvents = [...eventsToKeep, ...fetchedEvents];
    
    // Remove exact duplicates by ID (keep the fetched version)
    final finalEvents = <CustomAppointment>[];
    final seenIds = <String>{};
    
    // Add fetched events first (priority)
    for (final event in fetchedEvents) {
      if (!seenIds.contains(event.id)) {
        finalEvents.add(event);
        seenIds.add(event.id);
      }
    }
    
    // Add kept events (if not already seen)
    for (final event in eventsToKeep) {
      if (!seenIds.contains(event.id)) {
        finalEvents.add(event);
        seenIds.add(event.id);
      }
    }
    
    final oldCount = _events.length;
    _events = finalEvents;
    
    final syncEndTime = DateTime.now();
    final syncDuration = syncEndTime.difference(syncStartTime);
    final newCount = _events.length;
    final changesMade = (newCount - oldCount).abs();
    
    if (_debugLogging) {
      print('🔄 [EventProvider] Date range sync completed: ${changesMade} changes, now ${newCount} total events (${syncDuration.inMilliseconds}ms)');
      print('📊 [EventProvider] Kept ${eventsToKeep.length} existing, added ${fetchedEvents.length} new');
    }
    
    notifyListeners();
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
