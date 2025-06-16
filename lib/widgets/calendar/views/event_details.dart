import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../providers/calendarProvider.dart';
// import '../../../models/customApp.dart';
// import '../../../providers/eventProvider.dart';
import '../../../providers/authProvider.dart'; // Import AuthProvider
import '../../shared/categories.dart';
import '../controllers/event_deletion_controller.dart';
import '../controllers/event_save_controller.dart';
import 'calendar_selection_widget.dart';
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

  final _appFormKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _isEditing = false;
  bool _isLoading = false;

  List<Calendar> _selectedCalendars = [];
  String?
      _selectedCalendarId; // To store the ID of the single selected calendar

  bool _allDay = false;
  bool _isRecurring = false;
  String _recurrence = 'None';
  List<String> _selectedDays = [];
  String _selectedCategory = '';

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
    _allDay = widget._allDay ?? false;
    _selectedCalendarId =
        widget._calendarId; // Initialize _selectedCalendarId from widget
    _eventCalendar =
        TextEditingController(text: ''); // Initialize with empty text
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
        _eventDateController.text = DateFormat('MMMM d').format(selectedDate);
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
    print("Entering _selectCalendar in event details");
    final result = await showCalendarSelectionDialog(
      context,
    );

    if (result != null) {
      setState(() {
        _selectedCalendars = result;

        if (result.isNotEmpty) {
          _selectedCalendars = result;
          _selectedCalendarId = result.first.id;
          _eventCalendar.text = result.first.metadata.title;
        } else {
          _selectedCalendars = [];
          _selectedCalendarId = null;
          _eventCalendar.text = 'No calendar selected';
        }
      });
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

  Future<void> _saveEvent(BuildContext context) async {
    try {
      if (_appFormKey.currentState!.validate()) {
        _appFormKey.currentState!.save();
        setState(() {
          _isLoading = true;
        });

        // Use AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final String? currentUserId = authProvider.userId;

        if (currentUserId == null) {
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
          eventDate = DateFormat('MMMM d').parse(dateStr);
          if (eventDate.year != DateTime.now().year) {
            eventDate =
                DateTime(DateTime.now().year, eventDate.month, eventDate.day);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Invalid date format. Please use format like "April 26"'),
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

        // Validate end time is after start time
        if (endTime.hour < startTime.hour ||
            (endTime.hour == startTime.hour &&
                endTime.minute <= startTime.minute)) {
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

        // Create DateTime objects
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

        // Prepare event data
        final Map<String, dynamic> eventData = {
          'user_id': currentUserId, // Use currentUserId from AuthProvider
          'calendar_id': _selectedCalendars.isNotEmpty
              ? _selectedCalendars.first.id
              : null,
          'createdBy': currentUserId, // Use currentUserId from AuthProvider
          'event_organizer':
              currentUserId, // Use currentUserId from AuthProvider
          'event_title': _eventTitleController.text,
          'is_AllDay': _allDay,
          'recurrenceRule': _recurrence != 'None' ? _buildRecurrenceRule() : '',
          'category': _selectedCategory,
          'event_attendees': _eventParticipants.text,
          'event_body': _eventDescriptionController.text,
          'event_location': _eventLocation.text,
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
          'isUpdate': widget._id != null && widget._id!.isNotEmpty,
          'eventId': widget._id,
          'isAllDay': _allDay,
        };

        // Use the EventSaveController to save the event
        final success = await EventSaveController.saveEvent(context, eventData);

        if (success) {
          // Show success message before navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget._id != null && widget._id!.isNotEmpty
                  ? 'Event updated successfully!'
                  : 'Event created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Safe navigation - check if we can pop before attempting to
          if (Navigator.of(context).canPop()) {
            try {
              Navigator.of(context).pop(true); // Indicate success
            } catch (e) {
              print('Navigation error in _saveEvent: $e');
              // Don't attempt additional navigation here
            }
          }
          // No return true needed as it's Future<void>
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save event. Please try again.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } // No return false needed
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // No return false needed
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
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
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Text('Delete',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_isEditing) {
                                          _deleteEvent();
                                        } else {
                                          Navigator.of(context).pop();
                                        }
                                      },
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              child: Text('Save',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
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
