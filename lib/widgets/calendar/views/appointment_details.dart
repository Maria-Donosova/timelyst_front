import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/categories.dart'; // Imports the categories and their colors
import '../../calendar/views/recurrent_appointments_popup.dart';

class EventDetails extends StatefulWidget {
  EventDetails({
    required String? id,
    //required String creator,
    // List<UserProfile> userProfiles,
    // List<UserCalendar> userCalendars,
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
        // _userCalendars = userCalendars,
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
        _catColor = catColor,
        _participants = participants,
        _eventBody = body,
        _eventLocation = location;
  // _dateCreated = dateCreated,
  // _dateChanged = dateChanged,

  final String? _id;
  // final String _creator;
  // final String _eventOrganizer;
  // final List<UserProfile> _userProfiles;
  // final List<UserCalendar> _userCalendars;
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
  final Color? _catColor;
  final String? _participants;
  final String? _eventBody;
  final String? _eventLocation;

  // final DateTime _dateCreated;
  // final DateTime _dateChanged;

  @override
  State<EventDetails> createState() => EventDetailsScreentate();
}

class EventDetailsScreentate extends State<EventDetails> {
  late TextEditingController _eventSourceCalendar;
  late TextEditingController _eventTitleController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocation;
  late TextEditingController _eventRecurrenceRule;
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

  //function the changes the color of eventrepeat icon once the user chooses a recurrence pattern and clicked Saved within the _selectRecurrenceRule function
  // void _changeRecurringColor() {
  //   if (_recurrence != 'None') {
  //     setState(() {
  //       _isRecurring = true;
  //     });
  //   }
  // }

  // void _changeRecurringPattern() {
  //   if (_recurrence != 'None') {
  //     setState(() {
  //       _recurrence = _recurrence;
  //     });
  //   }
  // }

  //function to pick up the recurrence rule for the event based on user input. the recurrent pattern can be daily, weekly, monthly or yearly or custom set by day of the week
  // Future<void> _selectRecurrenceRule(BuildContext context) async {
  //   final selectedRecurrenceRule = await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return AlertDialog(
  //                 actions: [
  //                   TextButton(
  //                     style: ElevatedButton.styleFrom(
  //                         backgroundColor:
  //                             Theme.of(context).colorScheme.secondary),
  //                     child: Text('Delete',
  //                         style: TextStyle(
  //                           color: Theme.of(context).colorScheme.onPrimary,
  //                         )),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                   TextButton(
  //                     style: ElevatedButton.styleFrom(
  //                         backgroundColor:
  //                             Theme.of(context).colorScheme.secondary),
  //                     child: Text('Save',
  //                         style: TextStyle(
  //                           color: Theme.of(context).colorScheme.onPrimary,
  //                         )),
  //                     onPressed: () {
  //                       _changeRecurringColor();
  //                       _changeRecurringPattern();
  //                       Navigator.of(context).pop();
  //                     },
  //                   )
  //                 ],
  //                 title: const Text('Select Recurrence'),
  //                 content: Column(mainAxisSize: MainAxisSize.min, children: [
  //                   RadioListTile<String>(
  //                     activeColor: Theme.of(context).colorScheme.onPrimary,
  //                     title: Text('None'),
  //                     value: 'None',
  //                     groupValue: _recurrence,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _recurrence = value!;
  //                         _selectedDays.clear();
  //                       });
  //                     },
  //                   ),
  //                   RadioListTile<String>(
  //                     title: Text('Daily'),
  //                     value: 'Daily',
  //                     groupValue: _recurrence,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _recurrence = value!;
  //                         _selectedDays.clear();
  //                       });
  //                     },
  //                   ),
  //                   RadioListTile<String>(
  //                     title: Text('Weekly'),
  //                     value: 'Weekly',
  //                     groupValue: _recurrence,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _recurrence = value!;
  //                       });
  //                     },
  //                   ),
  //                   RadioListTile<String>(
  //                     title: Text('Yearly'),
  //                     value: 'Yearly',
  //                     groupValue: _recurrence,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _recurrence = value!;
  //                         _selectedDays.clear();
  //                       });
  //                     },
  //                   ),
  //                   if (_recurrence == 'Weekly')
  //                     Column(children: [
  //                       CheckboxListTile(
  //                         title: Text('Monday'),
  //                         value: _selectedDays.contains('Monday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Monday');
  //                             } else {
  //                               _selectedDays.remove('Monday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Tuesday'),
  //                         value: _selectedDays.contains('Tuesday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Tuesday');
  //                             } else {
  //                               _selectedDays.remove('Tuesday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Wednesday'),
  //                         value: _selectedDays.contains('Wednesday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Wednesday');
  //                             } else {
  //                               _selectedDays.remove('Wednesday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Thursday'),
  //                         value: _selectedDays.contains('Thursday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Thursday');
  //                             } else {
  //                               _selectedDays.remove('Thursday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Friday'),
  //                         value: _selectedDays.contains('Friday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Friday');
  //                             } else {
  //                               _selectedDays.remove('Friday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Saturday'),
  //                         value: _selectedDays.contains('Saturday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Saturday');
  //                             } else {
  //                               _selectedDays.remove('Saturday');
  //                             }
  //                           });
  //                         },
  //                       ),
  //                       CheckboxListTile(
  //                         title: Text('Sunday'),
  //                         value: _selectedDays.contains('Sunday'),
  //                         onChanged: (bool? value) {
  //                           setState(() {
  //                             if (value == true) {
  //                               _selectedDays.add('Sunday');
  //                             } else {
  //                               _selectedDays.remove('Sunday');
  //                             }
  //                           });
  //                         },
  //                       )
  //                     ])
  //                 ]));
  //           },
  //         );
  //       });
  //   if (selectedRecurrenceRule != null) {
  //     setState(() {
  //       _eventRecurrenceRule.text = selectedRecurrenceRule;
  //     });
  //   }
  // }

  //function returns a dialog and displays the external profiles and calendars to which the event can be added
  Future<void> _selectSourceCalendar(BuildContext context) async {
    final selectedSourceCalendar = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Accounts',
                style: Theme.of(context).textTheme.displaySmall),
            content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('test@gmail.com',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          CheckboxMenuButton(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                              child: Text('US Holidays')),
                          CheckboxMenuButton(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                              child: Text('Russian Holidays')),
                          CheckboxMenuButton(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                              child: Text('Birthdays')),
                        ],
                      ),
                    ),
                    Text('tryitout@gmail.com',
                        style: Theme.of(context).textTheme.bodyLarge),
                    CheckboxMenuButton(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                        child: Text('Holidays')),
                    Text('thisisit@icloud.com',
                        style: Theme.of(context).textTheme.bodyLarge),
                    CheckboxMenuButton(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                        child: Text('Holidays'))
                  ]),
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
                        },
                        // onTap: () {
                        //   _eventTitleController.value = TextEditingValue(
                        //     text: _eventTitleController.value.text,
                        //     // selection: TextSelection.fromPosition(
                        //     //   //TextPosition(offset: _newValue.length),
                        //     // ),
                        //   );
                        // },
                      ),
                    ),
                  ),
                  //profile icon button to select the associated user profile and the calendar to which the event is to be added
                  IconButton(
                    iconSize: Theme.of(context).iconTheme.size,
                    icon: Icon(Icons.person),
                    onPressed: () {
                      _selectSourceCalendar(context);
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
                              RecurrentAppointmentsPopUp;
                              //_selectRecurrenceRule(context);
                              setState(() {
                                // _isRecurring = !_isRecurring;
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
                            RecurrentAppointmentsPopUp(
                              recurrenceRule: _recurrence,
                            );
                            //_selectRecurrenceRule(context);
                            setState(() {
                              // _isRecurring = !_isRecurring;
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
                      onPressed: () {
                        if (_appFormKey.currentState!.validate()) {
                          print('saved');
                        } else {
                          Text('Fix the items');
                        }

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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
