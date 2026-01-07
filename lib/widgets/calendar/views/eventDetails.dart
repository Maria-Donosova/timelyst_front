import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../providers/calendarProvider.dart';
import '../../../providers/eventProvider.dart';
import '../../../providers/authProvider.dart';
import '../../../utils/rruleParser.dart';

import '../../../utils/timezoneUtils.dart';
import '../../shared/categories.dart';
import '../controllers/eventDeletionController.dart';
import '../../../models/customApp.dart';
import '../../shared/calendarSelection.dart';
import 'eventRecurrenceSelection.dart';

class EventDetails extends StatefulWidget {
  EventDetails({
    required String? id,
    String? subject,
    String? dateText,
    String? start,
    String? end,
    bool? isAllDay,
    String? recurrenceRule,
    String? catTitle,
    Color? catColor,
    String? participants,
    String? body,
    String? location,
    String? calendarId,
    DateTime? initialStartTime,
    DateTime? initialEndTime,
    String? recurrenceId,
    DateTime? originalStart,
    List<String>? exDates,
  })  : _id = id,
        _subject = subject,
        _dateText = dateText,
        _start = start,
        _end = end,
        _initialStartTime = initialStartTime,
        _initialEndTime = initialEndTime,
        _allDay = isAllDay,
        _recurrenceRule = recurrenceRule,
        _recurrenceId = recurrenceId,
        _originalStart = originalStart,
        _exDates = exDates,
        _catTitle = catTitle,
        _participants = participants,
        _eventBody = body,
        _eventLocation = location,
        _calendarId = calendarId;

  final String? _id;
  final String? _subject;
  final String? _dateText;
  final String? _start;
  final String? _end;
  final DateTime? _initialStartTime;
  final DateTime? _initialEndTime;
  final bool? _allDay;
  final String? _recurrenceRule;
  final String? _recurrenceId;
  final DateTime? _originalStart;
  final List<String>? _exDates;
  final String? _catTitle;
  final String? _participants;
  final String? _eventBody;
  final String? _eventLocation;
  final String? _calendarId;

  @override
  State<EventDetails> createState() => EventDetailsScreenState();
}

class EventDetailsScreenState extends State<EventDetails> {
  late TextEditingController _eventTitleController;
  late TextEditingController _eventStartDateController;
  late TextEditingController _eventEndDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocation;
  late TextEditingController _eventParticipants;
  late TextEditingController
      _eventCalendar; // Changed to non-nullable and initialized in initState
  late TextEditingController _eventConferenceDetails; // NEW: Conference details

  final _appFormKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _isEditing = false;
  bool _isLoading = false;

  DateTime? _startDate;
  DateTime? _endDate;

  List<Calendar> _selectedCalendars = [];
  String?
      _selectedCalendarId; // To store the ID of the single selected calendar
  Calendar? _eventCalendarInfo; // To store the calendar object for the event

  bool _allDay = false;
  bool _isRecurring = false;
  bool _hasReminder = false; // NEW: Reminder flag
  String _recurrence = 'None';
  List<String> _selectedDays = [];
  String _selectedCategory = '';

  // Recurrence information
  RecurrenceInfo? _recurrenceInfo;
  int? _occurrenceNumber;
  int? _totalOccurrences;

  // Helper function to get the appropriate icon based on calendar source
  IconData _getCalendarSourceIcon(CalendarSource source) {
    switch (source) {
      case CalendarSource.GOOGLE:
        return Icons.mail_outline;
      case CalendarSource.MICROSOFT:
        return Icons.window_outlined;
      case CalendarSource.APPLE:
        return Icons.apple;
      default:
        return Icons.calendar_today;
    }
  }

  @override
  void initState() {
    super.initState();
    _eventTitleController = TextEditingController(text: widget._subject);
    
    // Initialize start/end dates from initialStartTime/initialEndTime if available
    _startDate = widget._initialStartTime;
    _endDate = widget._initialEndTime;

    // Fallback parsing if needed (for backwards compatibility if called with strings)
    if (_startDate == null && widget._dateText != null) {
      try {
        _startDate = DateFormat('MMMM d', 'en_US').parse(widget._dateText!);
        _startDate = DateTime(DateTime.now().year, _startDate!.month, _startDate!.day);
        
        // If start date is parsed, we need a default end date too
        if (_endDate == null) {
          _endDate = _startDate;
        }
      } catch (e) {
        print('Error parsing initial date: $e');
      }
    }

    _eventStartDateController = TextEditingController(
      text: _startDate != null ? DateFormat('MMMM d', 'en_US').format(_startDate!) : widget._dateText
    );
    _eventEndDateController = TextEditingController(
      text: _endDate != null ? DateFormat('MMMM d', 'en_US').format(_endDate!) : widget._dateText
    );
    _eventStartTimeController = TextEditingController(text: widget._start);
    _eventEndTimeController = TextEditingController(text: widget._end);
    _eventLocation = TextEditingController(text: widget._eventLocation);
    _eventDescriptionController =
        TextEditingController(text: widget._eventBody);
    _selectedCategory = widget._catTitle ?? 'Misc';
    _eventParticipants = TextEditingController(text: widget._participants);
    _eventConferenceDetails = TextEditingController(text: ''); // NEW: Initialize conference details
    _allDay = widget._allDay ?? false;
    _selectedCalendarId = widget._calendarId;
    _eventCalendar = TextEditingController();

    // Use addPostFrameCallback to access the provider after the build cycle.
    // REMOVED: Moved to didChangeDependencies to ensure reactivity
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCalendarId != null) {
        final calendarProvider =
            Provider.of<CalendarProvider>(context, listen: false);
        final calendar = calendarProvider.getCalendarById(_selectedCalendarId!);
        print(
            '🔍 [EventDetails] Looking for calendar with ID: $_selectedCalendarId');
        print(
            '🔍 [EventDetails] Found calendar: ${calendar != null ? calendar.metadata.title : 'null'}');
        print('🔍 [EventDetails] Calendar source: ${calendar?.source.name}');
        if (calendar != null) {
          setState(() {
            _eventCalendar.text = calendar.metadata.title ?? 'No Title';
            _eventCalendarInfo = calendar; // Store the calendar object
          });
        }
      }
    });
    */

    // Check for recurrence rule OR recurrence ID (occurrences might not have the rule populated)
    if ((widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty) || 
        (widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty)) {
      
      print('🔍 [EventDetails] Identified as recurring event');
      _isRecurring = true;
      
      // Parse recurrence info for display if rule exists
      if (widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty) {
         _parseRecurrenceInfo();
         
         final parseRule = widget._recurrenceRule!;
         if (parseRule.contains('FREQ=DAILY') || parseRule.contains('DAILY')) {
           _recurrence = 'Daily';
         } else if (parseRule.contains('FREQ=WEEKLY') || parseRule.contains('WEEKLY')) {
           _recurrence = 'Weekly';
         } else if (parseRule.contains('FREQ=MONTHLY') || parseRule.contains('MONTHLY')) {
           _recurrence = 'Monthly';
         } else if (parseRule.contains('FREQ=YEARLY') || parseRule.contains('YEARLY')) {
           _recurrence = 'Yearly';
         } else {
           _recurrence = 'Custom';
         }
      }
    } else {
      print('🔍 [EventDetails] No recurrence rule found');
    }

    if (widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty) {
      print('🔍 [EventDetails] Found recurrence ID (Occurrence): ${widget._recurrenceId}');
      _isRecurring = true; // It is an occurrence of a recurring series
    }
  }

  /// Parses recurrence information and calculates occurrence number
  void _parseRecurrenceInfo() {
    if (widget._recurrenceRule == null || widget._recurrenceRule!.isEmpty) return;

    try {
      _recurrenceInfo = RRuleParser.parseRRule(widget._recurrenceRule);
      
      if (_recurrenceInfo != null) {
        // Calculate total occurrences
        _totalOccurrences = RRuleParser.getTotalOccurrences(
          widget._recurrenceRule!,
          widget._start != null ? _parseDateTime(widget._start!) : DateTime.now(),
        );

        // Calculate occurrence number if this is an occurrence (has originalStart or recurrenceId)
        if (widget._originalStart != null || widget._recurrenceId != null) {
          final eventStart = widget._start != null ? _parseDateTime(widget._start!) : DateTime.now();
          _occurrenceNumber = RRuleParser.calculateOccurrenceNumber(
            eventStart: eventStart,
            originalStart: widget._originalStart,
            rrule: widget._recurrenceRule!,
          );
        }
      }
    } catch (e) {
      print('Error parsing recurrence info: $e');
    }
  }

  /// Helper to parse date/time from string
  DateTime _parseDateTime(String dateTimeStr) {
    try {
      // Try parsing as ISO8601 first
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }

  /// Generates the occurrence text to display
  String _getOccurrenceText() {
    if (_occurrenceNumber != null && _totalOccurrences != null) {
      return 'This is occurrence $_occurrenceNumber of $_totalOccurrences';
    } else if (_occurrenceNumber != null) {
      return 'This is occurrence $_occurrenceNumber (ongoing series)';
    } else if (_totalOccurrences != null) {
      return 'Part of a series with $_totalOccurrences occurrences';
    } else if (_recurrenceInfo != null) {
      return 'Recurring: ${_recurrenceInfo!.getHumanReadableDescription()}';
    }
    return 'Recurring event';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Reactively update calendar info when provider changes
    if (_selectedCalendarId != null) {
      try {
        final calendarProvider = Provider.of<CalendarProvider>(context);
        final calendar = calendarProvider.getCalendarById(_selectedCalendarId!);
        
        if (calendar != null) {
          // Only update if something changed to avoid unnecessary rebuilds/loops
          if (_eventCalendarInfo?.id != calendar.id || _eventCalendar.text != calendar.metadata.title) {
            print('🔍 [EventDetails] Updating calendar info from provider: ${calendar.metadata.title} (${calendar.source.name})');
            _eventCalendar.text = calendar.metadata.title ?? 'No Title';
            _eventCalendarInfo = calendar;
            
            // Force a rebuild to ensure icon updates
            // setState(() {}); 
            // Note: didChangeDependencies triggers before build, so setState might not be needed if variables are used in build
            // But since we are updating local state variables that build depends on...
          }
        }
      } catch (e) {
        print('Error in didChangeDependencies: $e');
      }
    }
  }

  @override
  void dispose() {
    _eventStartDateController.dispose();
    _eventEndDateController.dispose();
    _eventStartTimeController.dispose();
    _eventEndTimeController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventLocation.dispose();
    _eventParticipants.dispose();
    _eventConferenceDetails.dispose(); // NEW: Dispose conference details
    _eventCalendar.dispose(); // Now non-nullable, direct disposal
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = (isStart ? _startDate : _endDate) ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = selectedDate;
          _eventStartDateController.text = DateFormat('MMMM d', 'en_US').format(selectedDate);
          
          // If end date is before start date, update end date to match start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
            _eventEndDateController.text = _eventStartDateController.text;
          }
        } else {
          _endDate = selectedDate;
          _eventEndDateController.text = DateFormat('MMMM d', 'en_US').format(selectedDate);
          
          // If start date is after end date, update start date to match end date
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
            _eventStartDateController.text = _eventEndDateController.text;
          }
        }
      });
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final normalizedTime = timeString.replaceAll(' ', ' ').trim();
      final regExp =
          RegExp(r'^(\d{1,2}):?(\d{2})?\s*([AP]M)?$', caseSensitive: false);
      final match = regExp.firstMatch(normalizedTime);

      if (match == null) {
        throw FormatException('Invalid time format: $timeString');
      }

      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3)?.toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $e');
      return TimeOfDay.now();
    }
  }

  /// Formats DateTime to ISO8601 string WITH timezone offset
  /// This preserves both the local time and timezone information
  /// Example: "2024-11-18T14:30:00.000-05:00"


  Future<void> _selectStart(BuildContext context, bool isStart) async {
    TimeOfDay initialStart = TimeOfDay.now();

    if (_eventStartTimeController.text.isNotEmpty) {
      initialStart = _parseTimeString(_eventStartTimeController.text);
    }

    final selectedStart = await showTimePicker(
      context: context,
      initialTime: initialStart,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (selectedStart != null) {
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        selectedStart.hour,
        selectedStart.minute,
      );
      final endDate = start.add(const Duration(minutes: 60));
      final newEnd = TimeOfDay.fromDateTime(endDate);

      setState(() {
        _eventStartTimeController.text = selectedStart.format(context);
        _eventEndTimeController.text = newEnd.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    TimeOfDay initialEnd = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 60)));
    
    if (_eventEndTimeController.text.isNotEmpty) {
      initialEnd = _parseTimeString(_eventEndTimeController.text);
    }

    final selectedEnd = await showTimePicker(
      context: context,
      initialTime: initialEnd,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (selectedEnd != null) {
      setState(() {
        _eventEndTimeController.text = selectedEnd.format(context);
      });
    }
  }

  void _setAllDay() {
    if (_allDay) {
      setState(() {
        _eventStartTimeController.text = '00:00';
        _eventEndTimeController.text = '23:59';
      });
    }
  }

  void _toggleAllDay(bool value) {
    setState(() {
      _allDay = value;
      _setAllDay();
    });
  }



  Future<void> _selectCalendar(BuildContext context) async {
    print('[EventDetails] Opening calendar selection with ${_selectedCalendars.length} selected calendars');
    final result = await showCalendarSelectionDialog(
      context,
      selectedCalendars: _selectedCalendars,
    );

    if (result != null) {
      print('[EventDetails] User selected ${result.length} calendars');
      setState(() {
        _selectedCalendars = result;

        if (result.isNotEmpty) {
          final firstCalendar = result.first;
          _selectedCalendarId = firstCalendar.id;
          _eventCalendar.text = firstCalendar.metadata.title ?? 'No Title';
          _eventCalendarInfo = firstCalendar; // Update the calendar info
          print('[EventDetails] Selected calendar: ${firstCalendar.metadata.title} (${firstCalendar.id})');
        } else {
          _selectedCalendarId = null;
          _eventCalendar.text = 'No calendar selected';
          _eventCalendarInfo = null; // Clear the calendar info
          print('[EventDetails] No calendar selected');
        }
      });
    } else {
      print('[EventDetails] Calendar selection was cancelled');
    }
  }

  /// Consolidated save method that handles both create and update operations
  /// for both time events and day events
  Future<void> _saveEvent(BuildContext context) async {
    try {
      if (_appFormKey.currentState!.validate()) {
        _appFormKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });

        // Get authentication credentials
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        final String? currentUserId = authProvider.userId;
        final String? authToken = await authProvider.authService.getAuthToken();

        if (currentUserId == null || authToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Authentication error. Please log in again.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Parse times
        TimeOfDay startTime, endTime;
        try {
          startTime = _parseTimeString(_eventStartTimeController.text);
          endTime = _parseTimeString(_eventEndTimeController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Invalid time format. Please use format like "2:30 PM"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Validate end time is after start time (only for same-day timed events)
        if (!_allDay && _startDate!.year == _endDate!.year && 
            _startDate!.month == _endDate!.month && 
            _startDate!.day == _endDate!.day && 
            (endTime.hour < startTime.hour ||
            (endTime.hour == startTime.hour &&
                endTime.minute <= startTime.minute))) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('End time must be after start time'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Create DateTime objects in local timezone
        // We don't convert to UTC because we want to preserve the user's input time
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          startTime.hour,
          startTime.minute,
        );

        final end = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          endTime.hour,
          endTime.minute,
        );

        print('📅 [EventDetails] User picked times:');
        print('  - Start Date: ${_startDate.toString()}');
        print('  - End Date: ${_endDate.toString()}');
        print('  - Start time: ${startTime.hour}:${startTime.minute}');
        print('  - End time: ${endTime.hour}:${endTime.minute}');
        print('  - Created DateTime objects:');
        print('    - start: $start');
        print('    - end: $end');
        print('    - start.timeZoneName: ${start.timeZoneName}');
        print('    - start.timeZoneOffset: ${start.timeZoneOffset}');

        // Get device timezone as IANA timezone name (e.g., "America/New_York")
        final deviceTimeZone = TimezoneUtils.getDeviceTimeZone();
        print('  - deviceTimeZone: $deviceTimeZone');

        // Prepare event data (common fields for both day and time events)
        final startFormatted = start.toUtc().toIso8601String();
        final endFormatted = end.toUtc().toIso8601String();

        print('📤 [EventDetails] Formatting for backend:');
        print('  - start formatted: $startFormatted');
        print('  - end formatted: $endFormatted');
        print('  - start_timeZone: $deviceTimeZone');
        print('  - end_timeZone: $deviceTimeZone');

        final Map<String, dynamic> eventData = {
          'user_id': currentUserId,
          'calendarId': _selectedCalendars.isNotEmpty
              ? _selectedCalendars.first.id
              : null,
          'eventTitle': _eventTitleController.text,
          'isAllDay': _allDay,
          'recurrenceRule': _recurrence != 'None' ? _buildRecurrenceRule() : '',
          'category': _selectedCategory,
          'description': _eventDescriptionController.text,
          'location': _eventLocation.text,
          'start': TimezoneUtils.formatDateTimeWithTimezone(start),
          'end': TimezoneUtils.formatDateTimeWithTimezone(end),
          'startTimeZone': deviceTimeZone,
          'endTimeZone': deviceTimeZone,
          'exdates': [],
        };

        print('📦 [EventDetails] Complete eventData being sent to service:');
        print('  ${eventData.toString()}');

        // Determine if this is an update or create operation
        final isUpdate = widget._id != null && widget._id!.isNotEmpty;

        print('🔍 [EventDetails] Save Event - isUpdate: $isUpdate');
        print('🔍 [EventDetails] Save Event - widget._recurrenceRule: ${widget._recurrenceRule}');
        print('🔍 [EventDetails] Save Event - widget._recurrenceId: ${widget._recurrenceId}');

        // Check if this is a recurring event being edited
        final isRecurringEdit = isUpdate && 
                                (widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty ||
                                 widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty);

        print('🔍 [EventDetails] Save Event - isRecurringEdit: $isRecurringEdit');

        // Ask user about edit scope for recurring events
        EditScope? editScope;
        if (isRecurringEdit) {
          editScope = await _showEditScopeDialog();
          if (editScope == null) {
            // User cancelled
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // Add edit scope to event data
          eventData['editScope'] = editScope == EditScope.thisOccurrence ? 'occurrence' : 'series';
        }

        // Determine which ID to use for update
        String? idToUpdate = widget._id;
        if (editScope == EditScope.allEvents && widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty) {
          // Editing series: use the master event ID
          idToUpdate = widget._recurrenceId;
        }

        // Call the appropriate EventProvider method based on event type and operation
        CustomAppointment? result;
        try {
          if (isUpdate) {
            result = await eventProvider.updateEvent(
              idToUpdate!,
              eventData,
            );
          } else {
            result = await eventProvider.createEvent(
              eventData,
            );
          }
        } catch (e) {
          print('Error saving event: $e');
        }

        if (result != null) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isUpdate
                    ? 'Event updated successfully!'
                    : 'Event created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Safe navigation
            if (Navigator.of(context).canPop()) {
              try {
                Navigator.of(context).pop(true); // Indicate success
              } catch (e) {
                print('Navigation error in _saveEvent: $e');
              }
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save event. Please try again.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Build recurrence rule string based on selected recurrence pattern
  String _buildRecurrenceRule() {
    String rule = '';

    switch (_recurrence) {
      case 'Daily':
        rule = 'FREQ=DAILY';
        break;
      case 'Weekly':
        if (_selectedDays.isNotEmpty) {
          // Convert day names to BYDAY format (MO,TU,WE,TH,FR,SA,SU)
          final byDays = _selectedDays
              .map((day) {
                switch (day) {
                  case 'Monday':
                    return 'MO';
                  case 'Tuesday':
                    return 'TU';
                  case 'Wednesday':
                    return 'WE';
                  case 'Thursday':
                    return 'TH';
                  case 'Friday':
                    return 'FR';
                  case 'Saturday':
                    return 'SA';
                  case 'Sunday':
                    return 'SU';
                  default:
                    return '';
                }
              })
              .where((day) => day.isNotEmpty)
              .join(',');

          rule = 'FREQ=WEEKLY;BYDAY=$byDays';
        } else {
          rule = 'FREQ=WEEKLY';
        }
        break;
      case 'Monthly':
        rule = 'FREQ=MONTHLY';
        break;
      case 'Yearly':
        rule = 'FREQ=YEARLY';
        break;
      case 'Custom':
        // Preserve original rule if it exists
        rule = widget._recurrenceRule ?? '';
        break;
      default:
        rule = '';
    }

    return rule;
  }

  // Method to delete an event
  Future<void> _deleteEvent({bool isOccurrence = false, bool isSeries = false}) async {
    // Determine if this is a recurring event (or part of one)
    final bool hasRule = widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty;
    final bool hasRecurrenceId = widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty;
    
    final checkIsRecurring = _isRecurring || hasRule || hasRecurrenceId;
                           
    print('🔍 [EventDetails] _deleteEvent - checkIsRecurring: $checkIsRecurring (isRecurring: $_isRecurring, hasRule: $hasRule, hasRecurrenceId: $hasRecurrenceId)');

    // If it's recurring and no specific scope was passed (i.e. clicked the generic Delete button),
    // ask the user for the scope first.
    if (checkIsRecurring && !isOccurrence && !isSeries) {
      final scope = await _showEditScopeDialog();
      if (scope == null) return; // User cancelled
      
      // Recursive call with the selected scope
      return _deleteEvent(
        isOccurrence: scope == EditScope.thisOccurrence,
        isSeries: scope == EditScope.allEvents,
      );
    }

    // Determine which ID to use
    String? idToDelete = widget._id;
    String deleteType = 'Event';

    if (isSeries) {
      // For series deletion, use the recurrenceId if available
      if (widget._recurrenceId != null && widget._recurrenceId!.isNotEmpty) {
        idToDelete = widget._recurrenceId;
        deleteType = 'Series';
      } else {
        // Fallback or error handling if recurrenceId is missing for a series delete
        print('Warning: Delete Series requested but recurrenceId is missing.');
        // Depending on backend logic, might still use widget._id or show error
      }
    } else if (isOccurrence) {
      deleteType = 'Occurrence';
      // For occurrence, we use the specific event ID (widget._id)
    } else if (checkIsRecurring) {
        // Fallback for recurring event where we somehow got here without scope
        // Default to occurrence deletion if ambiguous
        deleteType = 'Occurrence';
    }

    // Get calendar source name for the warning message
    final calendarSourceName = _eventCalendarInfo != null
        ? _eventCalendarInfo!.source.name.toUpperCase()
        : 'source calendar';

    // Show confirmation dialog with enhanced warning
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Delete $deleteType'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this ${deleteType.toLowerCase()}?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade700, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This ${deleteType.toLowerCase()} will be permanently deleted from both the database and your $calendarSourceName calendar. This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Determine delete scope string for backend
        String? deleteScope;
        if (isSeries) {
          deleteScope = 'series';
        } else if (isOccurrence) {
          deleteScope = 'occurrence';
        }
        
        print('🗑️ [EventDetails] Deleting event $idToDelete with scope: ${deleteScope ?? "default"}');
        
        // Pass deleteScope to the controller
        final success = await EventDeletionController.deleteEvent(
          context, 
          idToDelete, 
          _allDay,
          deleteScope: deleteScope,
        );

        if (success) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool _isSelected = false;

    final width = MediaQuery.of(context).size.width;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _appFormKey,
            child: SizedBox(
              width: width * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: width * 1,
                            child: TextFormField(
                              autocorrect: true,
                              enabled: true,
                              controller: _eventTitleController,
                              style: Theme.of(context).textTheme.displaySmall,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                hintText: 'Busy',
                                labelStyle:
                                    Theme.of(context).textTheme.bodyLarge,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Occurrence information display
                  if (_recurrenceInfo != null && (_occurrenceNumber != null || _totalOccurrences != null))
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.repeat, color: Colors.blue.shade700, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getOccurrenceText(),
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _eventStartDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _eventEndDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _eventStartTimeController,
                          readOnly: true,
                          onTap: () => _selectStart(context, true),
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _eventEndTimeController,
                          readOnly: true,
                          onTap: () => _selectEndTime(context),
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _allDay,
                        onChanged: (value) => _toggleAllDay(value!),
                      ),
                      Text('All Day'),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _eventCalendar,
                    readOnly: true,
                    onTap: () => _selectCalendar(context),
                    decoration: InputDecoration(
                      labelText: 'Calendar',
                      suffixIcon: _eventCalendarInfo != null
                          ? Icon(_getCalendarSourceIcon(_eventCalendarInfo!.source))
                          : Icon(Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: catColor(category),
                              radius: 5,
                            ),
                            SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final result = await showRecurrenceSelectionDialog(
                        context,
                        initialRecurrence: _recurrence,
                        initialSelectedDays: _selectedDays,
                      );
                      if (result != null) {
                        setState(() {
                          _recurrence = result['recurrence'];
                          _selectedDays = result['selectedDays'];
                          if (_recurrence != 'None') {
                            _isRecurring = true;
                          } else {
                            _isRecurring = false;
                          }
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Recurrence',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.repeat),
                      ),
                      child: Text(_recurrence),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (widget._id == null || _eventLocation.text.isNotEmpty) ...[
                    TextFormField(
                      controller: _eventLocation,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        suffixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  if (widget._id == null ||
                      _eventDescriptionController.text.isNotEmpty) ...[
                    TextFormField(
                      controller: _eventDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  if (widget._id == null || _eventParticipants.text.isNotEmpty) ...[
                    TextFormField(
                      controller: _eventParticipants,
                      decoration: InputDecoration(
                        labelText: 'Participants',
                        suffixIcon: Icon(Icons.people_outline),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete Button (Left Side)
                      if (widget._id != null && widget._id!.isNotEmpty) ...[
                        TextButton(
                          onPressed: () => _deleteEvent(),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.grey[900]!,
                            ),
                          ),
                        ),
                      ],
                      // Save Button (Right Side)
                      ElevatedButton(
                        onPressed: () => _saveEvent(context),
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  /// Shows a dialog to ask user whether to edit this occurrence or all events in the series
  Future<EditScope?> _showEditScopeDialog() async {
    return showDialog<EditScope>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.event_repeat, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('Edit Recurring Event'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is a recurring event. What would you like to edit?',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () => Navigator.pop(context, EditScope.thisOccurrence),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This occurrence',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Only this event will be changed',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.pop(context, EditScope.allEvents),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_repeat, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All events in the series',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'All occurrences will be changed',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Enum to represent the scope of editing for recurring events
enum EditScope {
  thisOccurrence,
  allEvents,
}
