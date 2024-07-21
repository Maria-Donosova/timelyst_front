import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/categories.dart'; // Imports the categories and their colors
import '../../models/user_profile.dart'; // Imports the file that contains the UserProfile class

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    super.key,
    //required String? id,
    required List<UserProfile> userProfiles,
    required String? eventTitle,
    required String? category,
    required String? categoryTitle,
    required String? dateText,
    required String? from,
    required String? to,
    required String? sourceCalendar,
    required String? calendarType,
    //required String? recurrenceId,
    required String? eventBody,
    required bool isAllDay,
    required String eventConferenceDetails,
    required String eventOrganizer,
    required String eventAttendees,
    required bool reminder,
    required bool holiday,
    //required List<DateTime>? exceptionDates,
    //required String? recurrenceRule,
    // required DateTime dateCreated,
    // required DateTime dateChanged,
    // required String creator,
  })  : //_id = id,
        _userProfiles = userProfiles,
        _eventTitle = eventTitle,
        _category = category,
        _catTitle = categoryTitle,
        _dateText = dateText,
        _startTimeText = from,
        _endTimeText = to,
        _sourceCalendar = sourceCalendar,
        _calendarType = calendarType,
        //_recurrenceId = recurrenceId,
        _eventBody = eventBody,
        _isAllDay = isAllDay,
        _eventConferenceDetails = eventConferenceDetails,
        _eventOrganizer = eventOrganizer,
        _eventAttendees = eventAttendees,
        _reminder = reminder,
        _holiday = holiday;
  // _exceptionDates = exceptionDates,
  // _recurrenceRule = recurrenceRule,
  // _dateCreated = dateCreated,
  // _dateChanged = dateChanged,
  // _creator = creator

  //final String? _id;
  final List<UserProfile> _userProfiles;
  final String? _eventTitle;
  final String? _category;
  final String? _catTitle;
  final String? _dateText;
  final String? _startTimeText;
  final String? _endTimeText;
  final String? _sourceCalendar;
  final String? _calendarType;
  //final String? _recurrenceId;
  final String? _eventBody;
  final bool _isAllDay;
  final String _eventConferenceDetails;
  final String _eventOrganizer;
  final String _eventAttendees;
  final bool _reminder;
  final bool _holiday;
  // final List<DateTime>? _exceptionDates;
  // final String? _recurrenceRule;
  // final DateTime _dateCreated;
  // final DateTime _dateChanged;
  // final String _creator;

  @override
  State<NewAppointment> createState() => NewAppointmentState();
}

class NewAppointmentState extends State<NewAppointment> {
  bool _isAllDay = false;
  bool _isRecurring = false;
  final _appForm = GlobalKey<FormState>();
  bool isChecked = false;
  String _recurrence = 'None';
  List<String> _selectedDays = [];
  String _selectedCategory = '';
  late TextEditingController _eventDateController;
  late TextEditingController _categoryController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;
  late TextEditingController _eventSourceCalendar;
  late TextEditingController _eventCalendarType;
  late TextEditingController _eventRecurrenceId;
  late TextEditingController _eventIsAllDay;
  late TextEditingController _eventConferenceDetails;
  late TextEditingController _eventOrganizer;
  late TextEditingController _eventAttendees;
  late TextEditingController _eventReminder;
  late TextEditingController _eventHoliday;
  late TextEditingController _eventExceptionDates;
  late TextEditingController _eventRecurrenceRule;

  @override
  void initState() {
    super.initState();
    // categories.forEach((category) {
    //   category = '';
    //},);
    _eventDateController = TextEditingController(text: widget._dateText);
    _eventStartTimeController = _eventStartTimeController =
        TextEditingController(text: widget._startTimeText);
    _eventEndTimeController = TextEditingController(text: widget._endTimeText);
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
    // final tapCaledarStartTime =
    //     TimeOfDay.fromDateTime(DateTime.parse(widget._startTimeText!));

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

  //function the changes the color of eventrepeat icon once the user chooses a recurrence pattern and clicked Saved within the _selectRecurrenceRule function
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
    }
  }

  //function to pick up the recurrence rule for the event based on user input. the recurrent pattern can be daily, weekly, monthly or yearly or custom set by day of the week
  Future<void> _selectRecurrenceRule(BuildContext context) async {
    final selectedRecurrenceRule = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        _changeRecurringColor();
                        _changeRecurringPattern();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                  title: const Text('Select Recurrence'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    RadioListTile<String>(
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
    if (selectedRecurrenceRule != null) {
      setState(() {
        _eventRecurrenceRule.text = selectedRecurrenceRule;
      });
    }
  }

  //function returns a dialog and displays the external profiles and calendars to which the event can be added
  Future<void> _selectSourceCalendar(BuildContext context) async {
    final List<UserProfile> userProfiles;

    final selectedSourceCalendar = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Your Calendars'),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Google'),
                      CheckboxMenuButton(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                          child: Text('Holidays'))
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Outlook'),
                  onTap: () {
                    Navigator.of(context).pop('Outlook');
                  },
                ),
                ListTile(
                  title: const Text('Apple'),
                  onTap: () {
                    Navigator.of(context).pop('Apple');
                  },
                ),
              ],
            ),
          );
        });

    if (selectedSourceCalendar != null) {
      setState(() {
        _eventSourceCalendar.text = selectedSourceCalendar;
      });
    }
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _eventStartTimeController.dispose();
    _eventEndTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isSelected = false;
    final _eventSubjController = TextEditingController();

    final selectedCategory = widget._category;
    var categoryColor = catColor(selectedCategory!);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Form(
      key: _appForm,
      child: SizedBox(
        width: width * 0.3,
        //height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: width * 0.8,
              child: Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextFormField(
                      autocorrect: true,
                      controller: _eventSubjController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        errorStyle: TextStyle(color: Colors.redAccent),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  //profile icon button to select the associated user profile and the calendar to which the event is to be added
                  SizedBox(
                    width: width * 0.1,
                    child: IconButton(
                      iconSize: 20,
                      icon: Icon(Icons.person),
                      onPressed: () {
                        _selectSourceCalendar(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 65,
                    child: TextFormField(
                        autocorrect: true,
                        controller: _eventDateController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          labelText: 'Event Date',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.redAccent),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          await _selectDate(context);
                        }),
                  ),
                  SizedBox(
                    width: 65,
                    child: TextFormField(
                      autocorrect: true,
                      controller: _eventStartTimeController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        labelStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        errorStyle: TextStyle(color: Colors.redAccent),
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
                    width: 65,
                    child: TextFormField(
                      autocorrect: true,
                      controller: _eventEndTimeController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        labelStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        errorStyle: TextStyle(color: Colors.redAccent),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 20,
                        onPressed: () {
                          setState(() {
                            _isAllDay = !_isAllDay;
                          });
                        },
                        color: _isAllDay ? Colors.black : Colors.grey,
                        icon: _isAllDay
                            ? Icon(Icons.hourglass_full_rounded)
                            : Icon(Icons.hourglass_empty_rounded),
                        tooltip: "All Day Event",
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        if (_recurrence == 'Weekly')
                          Tooltip(
                            message: _selectedDays.join(', '),
                            child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      _isRecurring ? Colors.black : Colors.grey,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                icon:
                                    Icon(size: 20, Icons.event_repeat_rounded),
                                label: Text(_recurrence.toString()),
                                //iconSize: 20,
                                //tooltip: _selectedDays.toString(),
                                onPressed: () {
                                  _selectRecurrenceRule(context);
                                  setState(() {
                                    // _isRecurring = !_isRecurring;
                                  });
                                }),
                          )
                        else
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    _isRecurring ? Colors.black : Colors.grey,
                                textStyle:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                              icon: Icon(size: 20, Icons.event_repeat_rounded),
                              label: Text(_recurrence.toString()),
                              //iconSize: 20,
                              //tooltip: _selectedDays.toString(),
                              onPressed: () {
                                _selectRecurrenceRule(context);
                                setState(() {
                                  // _isRecurring = !_isRecurring;
                                });
                              }),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                width: width,
                child: Wrap(
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
                        style: Theme.of(context).textTheme.bodyMedium,
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
                    //Rcontroller: ,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                      const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
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
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        setState(() {
                          print("event saved");
                          // runMutation({
//                       //   "task_description":
//                       //       _taskDescriptionController.text
//                       //           .trim(),
//                       //   // "task_type":
//                       //   //  _taskTypeController.text.trim(),
//                       //   "category": _selectedCategory,
//                       //   'userId': currUserId,
//                       // });;
                        });
                        Navigator.of(context).pop();
                      }),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        print("new event closed");
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
                    child: const Text('Close'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
