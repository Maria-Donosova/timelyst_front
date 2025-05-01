import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../models/customApp.dart';
import '../../../providers/eventProvider.dart';
import '../../../services/authService.dart';
import '../../shared/categories.dart';

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
        _eventLocation = location;

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

  @override
  State<EventDetails> createState() => EventDetailsScreentate();
}

class EventDetailsScreentate extends State<EventDetails> {
  late TextEditingController _eventTitleController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocation;
  late TextEditingController _eventParticipants;
  TextEditingController? _eventCalendar; // Made nullable

  final _appFormKey = GlobalKey<FormState>();
  bool isChecked = false;

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
    _selectedCategory = widget._catTitle ?? 'Misc'; // Added default value
    _eventParticipants = TextEditingController(text: widget._participants);
    _allDay = widget._allDay ?? false; // Added null check
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
    _eventCalendar?.dispose(); // Safe disposal
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

  Future<void> _selectEndTime(BuildContext context, bool isStart) async {
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
      setState(() {
        _recurrence = _recurrence;
      });
      //parseRRule(_recurrence);
    }
  }

  Future<void> _selectCalendar(BuildContext context) async {
    final selectedCalendar = await showDialog(
        context: context,
        builder: (BuildContext context) {
          // Use a Set to store unique categories
          Set<String> uniqueCategories = {};
          Map<String, List<Calendar>> categoryCalendarsMap = {};
          Map<String, bool> checkedCalendars = {};

          // Populate the Set and Map with unique categories and their calendars
          for (var calendar in calendars) {
            final category = calendar.category;

            if (!uniqueCategories.contains(category)) {
              uniqueCategories.add(category!);
              categoryCalendarsMap[category] =
                  []; // Initialize with an empty list
            }
            categoryCalendarsMap[category]!.add(calendar);
            // checkedCalendars[calendar.title] =
            //     calendars.contains(widget._userCalendars);
          }

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Calendars',
                    style: Theme.of(context).textTheme.displayMedium),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: uniqueCategories.map((category) {
                    final categoryCalendars = categoryCalendarsMap[category]!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                category,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: catColor(category),
                              radius: 4.5,
                            ),
                          ],
                        ),
                        if (categoryCalendars.isNotEmpty)
                          Column(
                            children: categoryCalendars.map((calendar) {
                              return Tooltip(
                                message: calendar.user,
                                child: CheckboxListTile(
                                  title: Text(
                                    calendar.title
                                    //+
                                    // ' ' +
                                    // calendar.sourceCalendar
                                    ,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: checkedCalendars[calendar.title],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkedCalendars[calendar.title] = value!;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary),
                    child: Text('Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary),
                    child: Text('Save',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
    if (selectedCalendar != null) {
      setState(() {
        _eventCalendar?.text = selectedCalendar;
      });
    }
  }

  Future<void> _selectRecurrenceRule(BuildContext context) async {
    final selectedRecurrenceRule = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  actions: [
                    TextButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      child: Text('Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    TextButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                      child: Text('Save',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
                      onPressed: () {
                        _changeRecurringColor();
                        _changeRecurringPattern();
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                  title: const Text('Select Recurrence'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    RadioListTile<String>(
                      activeColor: Theme.of(context).colorScheme.onPrimary,
                      title: Text('None'),
                      value: 'None',
                      groupValue: _recurrence,
                      onChanged: (value) {
                        setState(() {
                          _recurrence = value!;
                          _selectedDays.clear();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Daily'),
                      value: 'Daily',
                      groupValue: _recurrence,
                      onChanged: (value) {
                        setState(() {
                          _recurrence = value!;
                          _selectedDays.clear();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Weekly'),
                      value: 'Weekly',
                      groupValue: _recurrence,
                      onChanged: (value) {
                        setState(() {
                          _recurrence = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Yearly'),
                      value: 'Yearly',
                      groupValue: _recurrence,
                      onChanged: (value) {
                        setState(() {
                          _recurrence = value!;
                          _selectedDays.clear();
                        });
                      },
                    ),
                    if (_recurrence == 'Weekly')
                      Column(children: [
                        CheckboxListTile(
                          title: Text('Monday'),
                          value: _selectedDays.contains('Monday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Monday');
                              } else {
                                _selectedDays.remove('Monday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Tuesday'),
                          value: _selectedDays.contains('Tuesday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Tuesday');
                              } else {
                                _selectedDays.remove('Tuesday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Wednesday'),
                          value: _selectedDays.contains('Wednesday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Wednesday');
                              } else {
                                _selectedDays.remove('Wednesday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Thursday'),
                          value: _selectedDays.contains('Thursday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Thursday');
                              } else {
                                _selectedDays.remove('Thursday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Friday'),
                          value: _selectedDays.contains('Friday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Friday');
                              } else {
                                _selectedDays.remove('Friday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Saturday'),
                          value: _selectedDays.contains('Saturday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Saturday');
                              } else {
                                _selectedDays.remove('Saturday');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Sunday'),
                          value: _selectedDays.contains('Sunday'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedDays.add('Sunday');
                              } else {
                                _selectedDays.remove('Sunday');
                              }
                            });
                          },
                        )
                      ])
                  ]));
            },
          );
        });
  }

  // Future<bool> _saveEvent(BuildContext context) async {
  //   try {
  //     final authService = AuthService();
  //     final authToken = await authService.getAuthToken();
  //     final userId = await authService.getUserId();

  //     if (authToken == null || userId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Authentication error. Please log in again.')),
  //       );
  //       return false;
  //     }

  //     // Parse date
  //     final dateStr = _eventDateController.text;
  //     DateTime? eventDate;
  //     try {
  //       eventDate = DateFormat('MMMM d').parse(dateStr);
  //       if (eventDate.year != DateTime.now().year) {
  //         eventDate =
  //             DateTime(DateTime.now().year, eventDate.month, eventDate.day);
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Invalid date format')),
  //       );
  //       return false;
  //     }

  //     // Parse times
  //     TimeOfDay startTime, endTime;
  //     try {
  //       startTime = _parseTimeString(_eventStartTimeController.text);
  //       endTime = _parseTimeString(_eventEndTimeController.text);
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Invalid time format')),
  //       );
  //       return false;
  //     }

  //     // Create DateTime objects
  //     final startDateTime = DateTime(
  //       eventDate.year,
  //       eventDate.month,
  //       eventDate.day,
  //       startTime.hour,
  //       startTime.minute,
  //     );

  //     final endDateTime = DateTime(
  //       eventDate.year,
  //       eventDate.month,
  //       eventDate.day,
  //       endTime.hour,
  //       endTime.minute,
  //     );

  //     // Prepare event data with proper date handling
  //     final Map<String, dynamic> eventInput = {
  //       'user_id': userId,
  //       'createdBy': userId,
  //       'event_organizer': userId,
  //       'event_title': _eventTitleController.text,
  //       'is_AllDay': _allDay,
  //       'recurrenceRule': _recurrence != 'None' ? _buildRecurrenceRule() : '',
  //       'category': _selectedCategory,
  //       'event_attendees': _eventParticipants.text,
  //       'event_body': _eventDescriptionController.text,
  //       'event_location': _eventLocation.text,
  //       'event_startDate': startDateTime.toIso8601String(),
  //       'event_endDate': endDateTime.toIso8601String(),
  //     };

  //     // Handle server response with proper date parsing
  //     final eventProvider = Provider.of<EventProvider>(context, listen: false);
  //     final isUpdate = widget._id != null && widget._id!.isNotEmpty;

  //     CustomAppointment? result;
  //     if (isUpdate) {
  //       result = _allDay
  //           ? await eventProvider.updateDayEvent(
  //               widget._id!, eventInput, authToken)
  //           : await eventProvider.updateTimeEvent(
  //               widget._id!, eventInput, authToken);
  //     } else {
  //       result = _allDay
  //           ? await eventProvider.createDayEvent(eventInput, authToken)
  //           : await eventProvider.createTimeEvent(eventInput, authToken);
  //     }

  //     // Handle server response dates properly
  //     if (result != null) {
  //       // Ensure dates are properly parsed from server response
  //       // if (result.createdAt != null) {
  //       //   try {
  //       //     // Handle both ISO string and timestamp formats
  //       //     final createdAt = result.createdAt is String
  //       //         ? DateTime.parse(result.createdAt as String)
  //       //         : DateTime.fromMillisecondsSinceEpoch(result.createdAt as int);
  //       //     // Use the parsed date as needed
  //       //   } catch (e) {
  //       //     print('Error parsing server date: $e');
  //       //   }
  //       // }
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error saving event: ${e.toString()}')),
  //     );
  //     return false;
  //   }
  // }

  Future<bool> _saveEvent(BuildContext context) async {
    try {
      final authService = AuthService();
      final authToken = await authService.getAuthToken();
      final userId = await authService.getUserId();

      if (authToken == null || userId == null) {
        _showErrorMessage(
            context, 'Authentication error. Please log in again.');
        return false;
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
        _showErrorMessage(
            context, 'Invalid date format. Please use format like "April 26"');
        return false;
      }

      // Parse times
      TimeOfDay startTime, endTime;
      try {
        startTime = _parseTimeString(_eventStartTimeController.text);
        endTime = _parseTimeString(_eventEndTimeController.text);
      } catch (e) {
        _showErrorMessage(
            context, 'Invalid time format. Please use format like "2:30 PM"');
        return false;
      }

      // Validate end time is after start time
      if (endTime.hour < startTime.hour ||
          (endTime.hour == startTime.hour &&
              endTime.minute <= startTime.minute)) {
        _showErrorMessage(context, 'End time must be after start time');
        return false;
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
      final Map<String, dynamic> eventInput = {
        'user_id': userId,
        'createdBy': userId,
        'event_organizer': userId,
        'event_title': _eventTitleController.text,
        'is_AllDay': _allDay,
        'recurrenceRule': _recurrence != 'None' ? _buildRecurrenceRule() : '',
        'category': _selectedCategory,
        'event_attendees': _eventParticipants.text,
        'event_body': _eventDescriptionController.text,
        'event_location': _eventLocation.text,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

      // Save to server
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final isUpdate = widget._id != null && widget._id!.isNotEmpty;

      try {
        CustomAppointment? result;
        if (isUpdate) {
          result = _allDay
              ? await eventProvider.updateDayEvent(
                  widget._id!, eventInput, authToken)
              : await eventProvider.updateTimeEvent(
                  widget._id!, eventInput, authToken);
        } else {
          result = _allDay
              ? await eventProvider.createDayEvent(eventInput, authToken)
              : await eventProvider.createTimeEvent(eventInput, authToken);
        }

        if (result != null) {
          // Return success to the caller
          Navigator.of(context).pop(true);

          _showSuccessMessage(
              context,
              isUpdate
                  ? 'Event updated successfully!'
                  : 'Event created successfully!');
          return true;
        } else {
          _showErrorMessage(context, 'Failed to save event. Please try again.');
          return false;
        }
      } catch (e) {
        _showErrorMessage(context, 'Error saving event: ${e.toString()}');
        return false;
      }
    } catch (e) {
      _showErrorMessage(context, 'Unexpected error: ${e.toString()}');
      return false;
    }
  }

// Helper methods for showing messages
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    //bool _isSelected = false;
    final selectedCategory = widget._catTitle;
    var categoryColor = catColor(selectedCategory!);
    var isAllDay = widget._allDay;
    final width = MediaQuery.of(context).size.width;

    return Form(
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
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
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
                SizedBox(
                  width: 100,
                  child: TextFormField(
                      autocorrect: true,
                      controller: _eventDateController,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
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
                      errorStyle:
                          TextStyle(color: Theme.of(context).colorScheme.error),
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
                      errorStyle:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      await _selectEndTime(context, false);
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
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.tertiary,
                              textStyle:
                                  Theme.of(context).textTheme.displaySmall,
                            ),
                            icon: Icon(
                                size: Theme.of(context).iconTheme.size,
                                Icons.event_repeat_rounded),
                            onPressed: () {
                              _selectRecurrenceRule(context);
                              setState(() {
                                _isRecurring = !_isRecurring;
                              });
                            }),
                        Text(_recurrence.toString(),
                            style: Theme.of(context).textTheme.displaySmall),
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
                            textStyle: Theme.of(context).textTheme.displaySmall,
                          ),
                          icon: Icon(
                              size: Theme.of(context).iconTheme.size,
                              Icons.event_repeat_rounded),
                          onPressed: () {
                            _selectRecurrenceRule(context);
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
                          _selectedCategory = (selected ? category : null)!;
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
                            color: Theme.of(context).colorScheme.onPrimary,
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
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          onPressed: () {
                            setState(
                              () {
                                print("Delete");
                              },
                            );
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
                              color: Theme.of(context).colorScheme.onPrimary,
                            )),
                        onPressed: () async {
                          if (_appFormKey.currentState!.validate()) {
                            final success = await _saveEvent(context);
                            // Close the modal first
                            Navigator.of(context).pop();
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Event saved successfully')),
                              );
                              Navigator.of(context).pop();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
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

//dummy events
List<Calendar> calendars = [
  Calendar(
    user: '',
    kind: '',
    etag: '',
    id: '',
    //calendarId: '1',
    sourceCalendar: 'Google',
    title: 'Family',
    //email: 'test@gmail.com',
    //password: 'password',
    category: 'Kids',
    // events: [],
    // dateImported: DateTime.now(),
    // dateCreated: DateTime.now(),
    // dateUpdated: DateTime.now()
  ),
  Calendar(
    user: '',
    kind: '',
    etag: '',
    id: '',
    //calendarId: '1',
    sourceCalendar: 'Outlook',
    title: 'Work',
    //email: 'test@gmail.com',
    //password: 'password',
    category: 'Work',
    // events: [],
    // dateImported: DateTime.now(),
    // dateCreated: DateTime.now(),
    // dateUpdated: DateTime.now()
  ),
  Calendar(
    user: '',
    kind: '',
    etag: '',
    id: '',
    //calendarId: '1',
    sourceCalendar: 'Google',
    title: 'Personal',
    //email: 'test@gmail.com',
    //password: 'password',
    category: 'Study',
    // events: [],
    // dateImported: DateTime.now(),
    // dateCreated: DateTime.now(),
    // dateUpdated: DateTime.now()
  ),
];
