import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/calendars.dart';
import '../../../models/customApp.dart';
import '../../../providers/eventProvider.dart';
//import '../../../providers/authProvider.dart';
import '../../../services/authService.dart';

import '../../shared/categories.dart'; // Imports the categories and their colors

class EventDetails extends StatefulWidget {
  EventDetails({
    required String? id,
    //required String creator,
    // List<UserProfile> userProfiles,
    List<Calendar>? userCalendars,
    // String eventOrganizer,
    String? subject,
    String? dateText,
    String? startTime,
    String? endTime,
    // this.startTimeZone,
    // this.endTimeZone,
    bool? isAllDay,
    // required String? recurrenceId,
    String? recurrenceRule,
    // required List<DateTime>? recurrenceExceptionDates,
    String? catTitle,
    Color? catColor,
    String? participants,
    String? body,
    String? location,
    // this.resourceIds,
    // required DateTime dateCreated,
    // required DateTime dateChanged,
  })  : _id = id,
        // _creator = creator,
        // _userProfiles = userProfiles,
        _userCalendars = userCalendars,
        // _eventOrganizer = eventOrganizer,
        _subject = subject,
        _dateText = dateText,
        _startTimeText = startTime,
        _endTimeText = endTime,
        _allDay = isAllDay,
        // _recurrenceId = recurrenceId,
        _recurrenceRule = recurrenceRule,
        // _recurrenceExceptionDates = recurrenceExceptionDates,
        _catTitle = catTitle,
        _participants = participants,
        _eventBody = body,
        _eventLocation = location;
  // _dateCreated = dateCreated,
  // _dateChanged = dateChanged,

  final String? _id;
  // final String _creator;
  // final String _eventOrganizer;
  // final List<UserProfile> _userProfiles;
  final List<Calendar>? _userCalendars;
  final String? _subject;
  final String? _dateText;
  final String? _startTimeText;
  final String? _endTimeText;
  final bool? _allDay;
  // final String? _recurrenceId;
  final String? _recurrenceRule;
  // final List<DateTime>? _recurrenceExceptionDates;
  // final String? _reminder;
  // final String? _holiday;
  final String? _catTitle;

  final String? _participants;
  final String? _eventBody;
  final String? _eventLocation;

  // final DateTime _dateCreated;
  // final DateTime _dateChanged;

  @override
  State<EventDetails> createState() => EventDetailsScreentate();
}

class EventDetailsScreentate extends State<EventDetails> {
  late TextEditingController _eventCalendar;
  late TextEditingController _eventTitleController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocation;
  //late TextEditingController _eventRecurrenceRule;
  late TextEditingController _eventParticipants;

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
    _eventStartTimeController =
        TextEditingController(text: widget._startTimeText);
    _eventEndTimeController = TextEditingController(text: widget._endTimeText);

    _eventLocation = TextEditingController(text: widget._eventLocation);
    _eventDescriptionController =
        TextEditingController(text: widget._eventBody);
    _selectedCategory = widget._catTitle!;
    _eventParticipants = TextEditingController(text: widget._participants);
    _allDay = widget._allDay!;
    //_eventRecurrenceRule = TextEditingController(text: widget._recurrenceRule);
    _eventCalendar = TextEditingController(
        text: widget._userCalendars != null && widget._userCalendars!.isNotEmpty
            ? widget._userCalendars![0].title
            : '');
  }

//function to select date
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

//function to select start time based on user input via time picker and update end time by 30 minutes
  Future<void> _selectStartTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialStartTime;
    try {
      initialStartTime =
          TimeOfDay.fromDateTime(DateTime.parse(widget._startTimeText!));
    } catch (e) {
      initialStartTime =
          TimeOfDay.now(); // Fallback to current date if parsing fails
    }
    final selectedStartTime = await showTimePicker(
      context: context,
      initialTime: initialStartTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (selectedStartTime != null) {
      final newEndTime = selectedStartTime.replacing(
        hour: (selectedStartTime.hour + (selectedStartTime.minute + 30) ~/ 60) %
            24,
        minute: (selectedStartTime.minute + 30) % 60,
      );
      setState(() {
        _eventStartTimeController.text = selectedStartTime.format(context);
        _eventEndTimeController.text = newEndTime.format(context);
      });
    }
  }

//function to select end time
  Future<void> _selectEndTime(BuildContext context, bool isStartTime) async {
    final selectedEndTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30))),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    final selectedStartTime = _eventStartTimeController.text;
    if (selectedEndTime != null && selectedEndTime != selectedStartTime) {
      setState(() {
        _eventEndTimeController.text = selectedEndTime.format(context);
      });
    }
  }

  //function that updates _eventStartDateController and _eventEndDateController to (2024, 08, 18, 0, 00, 0) and (2024, 08, 18, 23, 59, 59) respectively once _allDay is set to true
  void _setAllDay() {
    if (_allDay == true) {
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

//  function to pick up the recurrence rule for the event based on user input. the recurrent pattern can be daily, weekly, monthly or yearly or custom set by day of the week
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

  //function returns a dialog and displays the external profiles and calendars to which the event can be added
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
            checkedCalendars[calendar.title] =
                calendars.contains(widget._userCalendars);
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
        _eventCalendar.text = selectedCalendar;
      });
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
    _eventCalendar.dispose();
    super.dispose();
  }

  // Save or update event based on form data
  Future<bool> _saveEvent(BuildContext context) async {
    print("Entering saveEvent in appointment builder");

    try {
      // Get the auth service for user ID and token
      final authService = AuthService();
      final authToken = await authService.getAuthToken();
      final userId = await authService.getUserId();

      print("User ID: $userId");
      print("Auth Token: $authToken");

      if (authToken == null || userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please log in again.')),
        );
        return false;
      }

      // Parse date and time strings to DateTime objects
      final dateStr = _eventDateController.text;
      final startTimeStr = _eventStartTimeController.text;
      final endTimeStr = _eventEndTimeController.text;

      // Parse date using DateFormat
      DateTime? eventDate;
      try {
        eventDate = DateFormat('MMMM d').parse(dateStr);
        // Set current year if the parsed date has a different year
        if (eventDate.year != DateTime.now().year) {
          eventDate =
              DateTime(DateTime.now().year, eventDate.month, eventDate.day);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid date format')),
        );
        return false;
      }

      // Create DateTime objects for start and end times
      int? startHour, startMinute, endHour, endMinute;

      // Handle different time formats (12-hour with AM/PM or 24-hour)
      try {
        // Try different time formats
        DateTime? startTime;

        // Try standard formats first
        if (startTimeStr.toLowerCase().contains('am') ||
            startTimeStr.toLowerCase().contains('pm')) {
          // Try various 12-hour formats with AM/PM
          final formats = ['h:mm a', 'h a', 'h:mm a', 'hh:mm a'];

          for (final format in formats) {
            try {
              startTime = DateFormat(format).parse(startTimeStr);
              break; // Exit loop if parsing succeeds
            } catch (e) {
              // Continue to next format
            }
          }

          if (startTime == null) {
            throw FormatException('Could not parse time: $startTimeStr');
          }
        } else {
          // 24-hour format
          final startTimeParts = startTimeStr.split(':');
          if (startTimeParts.length != 2) {
            throw FormatException('Invalid time format');
          }
          startHour = int.tryParse(startTimeParts[0]);
          startMinute = int.tryParse(startTimeParts[1]);

          if (startHour == null || startMinute == null) {
            throw FormatException('Invalid time values');
          }

          // Continue with the method execution
        }

        startHour = startTime?.hour;
        startMinute = startTime?.minute;
      } catch (e) {
        print('Error parsing start time: $e');
        print('Start time string: "$startTimeStr"');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid start time format: $startTimeStr')),
        );
        return false;
      }

      try {
        // Try different time formats
        DateTime? endTime;

        // Try standard formats first
        if (endTimeStr.toLowerCase().contains('am') ||
            endTimeStr.toLowerCase().contains('pm')) {
          // Try various 12-hour formats with AM/PM
          final formats = ['h:mm a', 'h a', 'h:mm a', 'hh:mm a'];

          for (final format in formats) {
            try {
              endTime = DateFormat(format).parse(endTimeStr);
              break; // Exit loop if parsing succeeds
            } catch (e) {
              // Continue to next format
            }
          }

          if (endTime == null) {
            throw FormatException('Could not parse time: $endTimeStr');
          }
        } else {
          // 24-hour format
          final endTimeParts = endTimeStr.split(':');
          if (endTimeParts.length != 2) {
            throw FormatException('Invalid time format');
          }
          endHour = int.tryParse(endTimeParts[0]);
          endMinute = int.tryParse(endTimeParts[1]);

          if (endHour == null || endMinute == null) {
            throw FormatException('Invalid time values');
          }

          // Continue with the method execution
        }

        endHour = endTime?.hour;
        endMinute = endTime?.minute;
      } catch (e) {
        print('Error parsing end time: $e');
        print('End time string: "$endTimeStr"');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid end time format: $endTimeStr')),
        );
        return false;
      }

      if (startHour == null ||
          startMinute == null ||
          endHour == null ||
          endMinute == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid time format')),
        );
        return false;
      }

      final startDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        startHour,
        startMinute,
      );

      final endDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        endHour,
        endMinute,
      );

      // Prepare event data with proper date format for models
      final Map<String, dynamic> eventInput = {
        'user_id': userId,
        'createdBy': userId,
        'user_calendars':
            widget._userCalendars != null && widget._userCalendars!.isNotEmpty
                ? widget._userCalendars!.map((cal) => cal.id ?? '').toList()
                : [],
        'source_calendar':
            widget._userCalendars != null && widget._userCalendars!.isNotEmpty
                ? widget._userCalendars![0].sourceCalendar ?? ''
                : '',
        'event_organizer': userId,
        'event_title': _eventTitleController.text,
        // Format dates according to the model requirements
        'start': _allDay
            ? {'date': startDateTime.toIso8601String().split('T')[0]}
            : {'dateTime': startDateTime.toIso8601String()},
        'end': _allDay
            ? {'date': endDateTime.toIso8601String().split('T')[0]}
            : {'dateTime': endDateTime.toIso8601String()},
        'is_AllDay': _allDay,
        'recurrence': _recurrence != 'None' ? [_buildRecurrenceRule()] : [],
        'category': _selectedCategory,
        'event_attendees': _eventParticipants.text,
        'event_body': _eventDescriptionController.text,
        'event_location': _eventLocation.text,
      };

      // Keep these fields for backward compatibility with API
      eventInput['event_startDate'] = startDateTime.toIso8601String();
      eventInput['event_endDate'] = endDateTime.toIso8601String();

      // Get the event provider
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Determine if this is a create or update operation
      final isUpdate = widget._id != null && widget._id!.isNotEmpty;

      // Call the appropriate method based on all-day status and create/update
      CustomAppointment? result;

      if (isUpdate) {
        // Update existing event
        if (_allDay) {
          result = await eventProvider.updateDayEvent(
              widget._id!, eventInput, authToken);
        } else {
          result = await eventProvider.updateTimeEvent(
              widget._id!, eventInput, authToken);
        }
      } else {
        // Create new event
        if (_allDay) {
          result = await eventProvider.createDayEvent(eventInput, authToken);
        } else {
          result = await eventProvider.createTimeEvent(eventInput, authToken);
        }
      }

      return result != null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: ${e.toString()}')),
      );
      return false;
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
                      await _selectStartTime(context, true);
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
                mainAxisAlignment: MainAxisAlignment.end,
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
                          // runMutation({
                          //                           //   "event_subj": _eventSubjController.text.trim(),
                          //                           //   "event_startdate":
                          //                           //       _eventStartDateController.text.trim(),
                          //                           //   "event_enddate": _eventEndDateController.text.trim(),
                          //                           // });
                          //                           print("event mutation");
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('Close',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
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
                                content:
                                    Text('Please fix the errors in the form')),
                          );
                        }
                      }),
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
