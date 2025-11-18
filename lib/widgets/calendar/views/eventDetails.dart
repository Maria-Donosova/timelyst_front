import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../providers/calendarProvider.dart';
import '../../../providers/eventProvider.dart';
import '../../../providers/authProvider.dart';
import '../../../services/eventsService.dart';
import '../../../utils/timezoneUtils.dart';
import '../../shared/categories.dart';
import '../controllers/eventDeletionController.dart';
import '../../shared/calendarSelection.dart';
//import 'event_recurrence_selector.dart';
// import 'event_category_selector.dart';
// import 'event_date_time_picker.dart';

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
  })  : _id = id,
        _subject = subject,
        _dateText = dateText,
        _start = start,
        _end = end,
        _allDay = isAllDay,
        _recurrenceRule = recurrenceRule,
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
      case CalendarSource.google:
        return Icons.mail_outline;
      case CalendarSource.outlook:
        return Icons.window_outlined;
      case CalendarSource.apple:
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
            _eventCalendar.text = calendar.metadata.title;
            _eventCalendarInfo = calendar; // Store the calendar object
          });
        }
      }
    });
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
  String _formatDateTimeWithTimezone(DateTime dateTime) {
    return TimezoneUtils.formatDateTimeWithTimezone(dateTime);
  }

  Future<void> _selectStart(BuildContext context, bool isStart) async {
    TimeOfDay initialStart = TimeOfDay.now();

    if (widget._start != null && widget._start!.isNotEmpty) {
      initialStart = _parseTimeString(widget._start!);
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
      final endDate = start.add(const Duration(minutes: 30));
      final newEnd = TimeOfDay.fromDateTime(endDate);

      setState(() {
        _eventStartTimeController.text = selectedStart.format(context);
        _eventEndTimeController.text = newEnd.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final selectedEnd = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30))),
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

  //  function the changes the color of eventrepeat icon once the user chooses a recurrence pattern and clicked Saved within the _selectRecurrenceRule function
  void _changeRecurringColor() {
    if (_recurrence != 'None') {
      setState(() {
        _isRecurring = true;
      });
    }
  }

  void _changeRecurringPattern() {
    if (_recurrence != 'None') {
      // No need to set _recurrence to itself
      // Just call parseRRule if needed
      //parseRRule(_recurrence);
    }
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
          _eventCalendar.text = firstCalendar.metadata.title;
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

  // Future<void> _selectRecurrenceRule(BuildContext context) async {
  //   final result = await showRecurrenceSelectionDialog(
  //     context,
  //     initialRecurrence: _recurrence,
  //     initialSelectedDays: _selectedDays,
  //   );

  //   if (result != null) {
  //     setState(() {
  //       _recurrence = result['recurrence'];
  //       _selectedDays = List<String>.from(result['selectedDays']);

  //       // Update UI state based on selection
  //       if (_recurrence != 'None') {
  //         _isRecurring = true;
  //       }
  //     });
  //   }
  // }

  // Future<void> _selectCategory(BuildContext context) async {
  //   final result = await showCategorySelectionDialog(
  //     context,
  //     initialCategory: _selectedCategory,
  //   );

  //   if (result != null) {
  //     setState(() {
  //       _selectedCategory = result;
  //     });
  //   }
  // }

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

        // Get device timezone as IANA timezone name (e.g., "America/New_York")
        final deviceTimeZone = TimezoneUtils.getDeviceTimeZone();

        // Prepare event data (common fields for both day and time events)
        final Map<String, dynamic> eventData = {
          'user_id': currentUserId,
          'user_calendars': _selectedCalendars.isNotEmpty
              ? _selectedCalendars.first.id
              : null,
          'source_calendar': _selectedCalendars.isNotEmpty
              ? _selectedCalendars.first.id
              : null, // NEW: Source calendar mapping
          'createdBy': currentUserId,
          'event_organizer': currentUserId,
          'event_title': _eventTitleController.text,
          'is_AllDay': _allDay,
          'recurrenceRule': _recurrence != 'None' ? _buildRecurrenceRule() : '',
          'recurrenceId': '', // NEW: Recurrence ID for instances
          'exceptionDates': [], // NEW: Exception dates for recurring events
          'category': _selectedCategory,
          'event_attendees': _eventParticipants.text,
          'event_body': _eventDescriptionController.text,
          'event_location': _eventLocation.text,
          'event_ConferenceDetails': _eventConferenceDetails.text, // NEW: Conference details
          'reminder': _hasReminder, // NEW: Reminder flag
          'holiday': false, // NEW: Holiday flag (default false)
          // Format datetime WITH timezone offset to preserve timezone information
          'start': _formatDateTimeWithTimezone(start),
          'end': _formatDateTimeWithTimezone(end),
          // NEW: Separate timezone fields for start and end
          'start_timeZone': deviceTimeZone,
          'end_timeZone': deviceTimeZone,
        };

        // Add timeZone for TimeEvents only (not for DayEvents)
        // Keep this for backward compatibility with backend
        if (!_allDay) {
          eventData['timeZone'] = deviceTimeZone; // Legacy: Single timezone for time events
          eventData['time_EventInstance'] = []; // NEW: Time event instances
        } else {
          eventData['timeZone'] = deviceTimeZone; // Add timezone for day events too
          eventData['day_EventInstance'] = ''; // NEW: Day event instance
        }

        // Determine if this is an update or create operation
        final isUpdate = widget._id != null && widget._id!.isNotEmpty;

        // Call the appropriate EventService method based on event type and operation
        bool success = false;
        try {
          if (_allDay) {
            // Day Event (All-day event)
            if (isUpdate) {
              final result = await EventService.updateDayEvent(
                widget._id!,
                eventData,
                authToken,
              );
              success = result != null;
            } else {
              final result = await EventService.createDayEvent(
                eventData,
                authToken,
              );
              success = result != null;
            }
          } else {
            // Time Event (Timed event)
            if (isUpdate) {
              final result = await EventService.updateTimeEvent(
                widget._id!,
                eventData,
                authToken,
              );
              success = result != null;
            } else {
              final result = await EventService.createTimeEvent(
                eventData,
                authToken,
              );
              success = result != null;
            }
          }
        } catch (e) {
          print('Error saving event: $e');
          success = false;
        }

        if (success) {
          // Invalidate cache to force fresh data on next fetch
          eventProvider.invalidateCache();

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
  Future<void> _deleteEvent() async {
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
            const Text('Delete Event'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this event?',
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
                      'This event will be permanently deleted from both the database and your $calendarSourceName calendar. This action cannot be undone.',
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
        final success = await EventDeletionController.deleteEvent(
            context, widget._id, _allDay);

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
    final selectedCategory = widget._catTitle ?? 'Misc';
    var categoryColor = catColor(selectedCategory);
    var isAllDay = widget._allDay;
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
                                errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide a value.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        //profile icon button to select the associated the calendar to which the event is to be added
                        IconButton(
                          iconSize: Theme.of(context).iconTheme.size,
                          icon: Icon(Icons.person),
                          onPressed: () {
                            _selectCalendar(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    children: [
                      TextFormField(
                        controller: _eventCalendar,
                        readOnly: true, // Make it read-only
                        decoration: InputDecoration(
                          labelText: 'Calendar',
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                            autocorrect: true,
                            controller: _eventDateController,
                            style: Theme.of(context).textTheme.displaySmall,
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle:
                                  Theme.of(context).textTheme.bodyMedium,
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.datetime,
                            onTap: () async {
                              await _selectDate(context);
                            }),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          autocorrect: true,
                          controller: _eventStartTimeController,
                          style: Theme.of(context).textTheme.displaySmall,
                          decoration: InputDecoration(
                            labelText: 'Begin',
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            border: InputBorder.none,
                            errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.datetime,
                          onTap: () async {
                            await _selectStart(context, true);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          autocorrect: true,
                          controller: _eventEndTimeController,
                          style: Theme.of(context).textTheme.displaySmall,
                          decoration: InputDecoration(
                            labelText: 'End',
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            border: InputBorder.none,
                            errorStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.datetime,
                          onTap: () async {
                            await _selectEndTime(context);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      IconButton(
                        iconSize: Theme.of(context).iconTheme.size,
                        onPressed: () {
                          setState(() {
                            _allDay = !_allDay;
                            _setAllDay();
                            isAllDay = !isAllDay!;
                          });
                        },
                        color: _allDay
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.tertiary,
                        icon: _allDay
                            ? Icon(Icons.hourglass_full_rounded)
                            : Icon(Icons.hourglass_empty_rounded),
                        tooltip: "All Day",
                      ),
                      if (_recurrence == 'Weekly')
                        Tooltip(
                          message: _selectedDays.join(', '),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: _isRecurring
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                  icon: Icon(
                                      size: Theme.of(context).iconTheme.size,
                                      Icons.event_repeat_rounded),
                                  onPressed: () {
                                    //_selectRecurrenceRule(context);
                                    setState(() {
                                      _isRecurring = !_isRecurring;
                                    });
                                  }),
                              Text(_recurrence.toString(),
                                  style:
                                      Theme.of(context).textTheme.displaySmall),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: _isRecurring
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.tertiary,
                                  textStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                icon: Icon(
                                    size: Theme.of(context).iconTheme.size,
                                    Icons.event_repeat_rounded),
                                onPressed: () {
                                  //_selectRecurrenceRule(context);
                                  setState(() {
                                    _isRecurring = !_isRecurring;
                                  });
                                }),
                            Text(
                              _recurrence.toString(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: SizedBox(
                      width: width,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: categories.map((String category) {
                          categoryColor = catColor(category);
                          return ChoiceChip(
                            visualDensity: VisualDensity.standard,
                            avatar: CircleAvatar(
                              backgroundColor: categoryColor,
                              radius: 4.5,
                            ),
                            label: Text(
                              category,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            selected: _selectedCategory == category,
                            selectedColor: Colors.grey.shade200,
                            backgroundColor: Colors.white,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedCategory =
                                    (selected ? category : null)!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: width * 0.8,
                      child: TextFormField(
                        autocorrect: true,
                        controller: _eventLocation,
                        style: Theme.of(context).textTheme.displaySmall,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: width * 0.8,
                      child: TextFormField(
                          autocorrect: true,
                          controller: _eventParticipants,
                          style: Theme.of(context).textTheme.displaySmall,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Participants',
                            labelStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            const pattern =
                                r'^([\w-\.]+@([\w-]+\.)+[\w-]{2,4},\s*)*[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$|^$';
                            final regExp = RegExp(pattern);
                            if (!regExp.hasMatch(value!)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: width * 0.8,
                      child: TextFormField(
                        autocorrect: true,
                        controller: _eventConferenceDetails,
                        style: Theme.of(context).textTheme.displaySmall,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Conference Details (Zoom, Google Meet, etc.)',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          hintText: 'https://zoom.us/j/...',
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: width * 0.8,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _hasReminder,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasReminder = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Set Reminder',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: 500,
                      child: TextFormField(
                        autocorrect: true,
                        controller: _eventDescriptionController,
                        style: Theme.of(context).textTheme.displaySmall,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          fillColor: Colors.grey,
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              setState(() {
                                print("Cancel");
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )),
                          ),
                        ),
                        Row(
                          children: [
                            // Calendar source icon in bottom right corner
                            if (_eventCalendarInfo != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Tooltip(
                                  message:
                                      'Source: ${_eventCalendarInfo!.source.name}',
                                  child: Icon(
                                    _getCalendarSourceIcon(
                                        _eventCalendarInfo!.source),
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            // Only show Delete button for existing events
                            if (widget._id != null && widget._id!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                  ),
                                  child: Text('Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                  onPressed: _isLoading ? null : _deleteEvent,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Text('Save',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (_appFormKey.currentState!
                                            .validate()) {
                                          await _saveEvent(context);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Please fix the errors in the form')),
                                          );
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
