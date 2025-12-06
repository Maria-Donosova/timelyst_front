import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../providers/calendarProvider.dart';
import '../../../providers/eventProvider.dart';
import '../../../providers/authProvider.dart';

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
    String? recurrenceId,
  })  : _id = id,
        _subject = subject,
        _dateText = dateText,
        _start = start,
        _end = end,
        _allDay = isAllDay,
        _recurrenceRule = recurrenceRule,
        _recurrenceId = recurrenceId,
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
  final bool? _allDay;
  final String? _recurrenceRule;
  final String? _recurrenceId;
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
  late TextEditingController _eventDateController;
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
    _eventDateController = TextEditingController(text: widget._dateText);
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

    if (widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty) {
      if (widget._recurrenceRule!.contains('DAILY')) {
        _recurrence = 'Daily';
      } else if (widget._recurrenceRule!.contains('WEEKLY')) {
        _recurrence = 'Weekly';
      } else if (widget._recurrenceRule!.contains('YEARLY')) {
        _recurrence = 'Yearly';
      }
    }
  }

  @override
  void dispose() {
    _eventDateController.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (_eventDateController.text.isNotEmpty) {
        final parsedDate = DateFormat('MMMM d', 'en_US').parse(_eventDateController.text);
        initialDate = DateTime(DateTime.now().year, parsedDate.month, parsedDate.day);
      }
    } catch (e) {
      print('Error parsing initial date: $e');
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _eventDateController.text = DateFormat('MMMM d', 'en_US').format(selectedDate);
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

        // Parse date
        final dateStr = _eventDateController.text;
        DateTime? eventDate;
        try {
          eventDate = DateFormat('MMMM d', 'en_US').parse(dateStr);
          if (eventDate.year != DateTime.now().year) {
            eventDate =
                DateTime(DateTime.now().year, eventDate.month, eventDate.day);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Invalid date format. Please use format like "November 6"'),
              behavior: SnackBarBehavior.floating,
            ),
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

        // Validate end time is after start time (only for non-all-day events)
        if (!_allDay && (endTime.hour < startTime.hour ||
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
          eventDate.year,
          eventDate.month,
          eventDate.day,
          startTime.hour,
          startTime.minute,
        );

        final end = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          endTime.hour,
          endTime.minute,
        );

        print('📅 [EventDetails] User picked times:');
        print('  - Date: ${eventDate.toString()}');
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
          'start': startFormatted,
          'end': endFormatted,
          'startTimeZone': deviceTimeZone,
          'endTimeZone': deviceTimeZone,
          'exdates': [],
        };

        print('📦 [EventDetails] Complete eventData being sent to service:');
        print('  ${eventData.toString()}');

        // Determine if this is an update or create operation
        final isUpdate = widget._id != null && widget._id!.isNotEmpty;

        // Call the appropriate EventProvider method based on event type and operation
        CustomAppointment? result;
        try {
          if (isUpdate) {
            result = await eventProvider.updateEvent(
              widget._id!,
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
      case 'Yearly':
        rule = 'FREQ=YEARLY';
        break;
      default:
        rule = '';
    }

    return rule;
  }

  // Method to delete an event
  Future<void> _deleteEvent({bool isOccurrence = false, bool isSeries = false}) async {
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
              'Are you sure you want to delete this $deleteType.toLowerCase()?',
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
                      'This $deleteType.toLowerCase() will be permanently deleted from both the database and your $calendarSourceName calendar. This action cannot be undone.',
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
        // Use the appropriate ID for deletion
        final success = await EventDeletionController.deleteEvent(
            context, idToDelete, _allDay);

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
                  TextFormField(
                    controller: _eventDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
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
                  TextFormField(
                    controller: _eventLocation,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _eventDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete Buttons (Left Side)
                      if (widget._id != null && widget._id!.isNotEmpty) ...[
                        if (_isRecurring || (widget._recurrenceRule != null && widget._recurrenceRule!.isNotEmpty)) ...[
                          // Recurring Event Buttons
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _deleteEvent(isOccurrence: true),
                                child: Text(
                                  'Delete Occurrence',
                                  style: TextStyle(
                                    color: Colors.grey[900]!,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _deleteEvent(isSeries: true),
                                child: Text(
                                  'Delete Series',
                                  style: TextStyle(
                                    color: Colors.grey[900]!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Non-Recurring Event Button
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
}
