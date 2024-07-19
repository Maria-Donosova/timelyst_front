import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/categories.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    super.key,
    //required String? id,
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
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: width * 0.8,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
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
                      Row(children: [
                        IconButton(
                          iconSize: 20,
                          onPressed: () {
                            setState(() {
                              _isRecurring = !_isRecurring;
                            });
                          },
                          color: _isRecurring ? Colors.black : Colors.grey,
                          icon: Icon(Icons.event_repeat_rounded),
                        ),
                        Text('Weekly'),
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
                  spacing: 1.0,
                  children: categories.map((String category) {
                    category = category;
                    categoryColor = catColor(category);
                    return ChoiceChip(
                      visualDensity: VisualDensity.comfortable,
                      avatar: CircleAvatar(
                        backgroundColor: categoryColor,
                        radius: 4.5,
                      ),
                      label: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      selected: _isSelected,
                      selectedColor: Colors.grey.shade200,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _isSelected = !_isSelected;
                        });
                      },
                    );
                  }).toList(),
                ),
                // DropdownButton<String>(
                //     hint: Text(
                //       'Category',
                //       style: Theme.of(context).textTheme.titleSmall,
                //     ),
                //     icon: const Icon(Icons.arrow_downward),
                //     iconSize: 14,
                //     items: categories.map((category) {
                //       return DropdownMenuItem(
                //         child: Text(category),
                //         value: category,
                //       );
                //     }).toList(),
                //     onChanged: (newValue) {
                //       setState(() {
                //         // Handle category selection
                //       });
                //       Navigator.of(context).pop();
                //     }),
              ),
            ),
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   IconButton(onPressed: () {}, icon: Icon(Icons.view_day_outlined)),
            //   IconButton(onPressed: () {}, icon: Icon(Icons.queue_rounded)),
            //   IconButton(
            //       onPressed: () {}, icon: Icon(Icons.question_mark_outlined)),
            //   IconButton(
            //       onPressed: () {}, icon: Icon(Icons.holiday_village_outlined)),
            // ]),

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
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
            //   IconButton(onPressed: () {}, icon: Icon(Icons.calendar_today)),
            //   IconButton(onPressed: () {}, icon: Icon(Icons.person_2_outlined)),
            // ]),
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




// class NewAppointment extends StatefulWidget {
//   @override
//   _NewAppointmentState createState() => _NewAppointmentState();
// }

// class _NewAppointmentState extends State<NewAppointment> {
//   final _formKey = GlobalKey<FormState>();
//   String _eventTitle = '';
//   String _subject = '';
//   DateTime? _selectedDate;
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;
//   bool _isAllDay = false;
//   bool _isRecurring = false;
//   String _recurrencePattern = 'Mon, Thur';
//   String _category = '';
//   List<String> _participants = [];
//   String _description = '';

//   final List<String> _categories = [
//     'Work',
//     'Friends',
//     'Personal',
//     'Family',
//     'Kids',
//     'Generic'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Event Title'),
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.account_circle),
//             onSelected: (String result) {
//               // Handle account selection
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               PopupMenuItem<String>(
//                 value: 'account1',
//                 child: Text('Account 1'),
//               ),
//               PopupMenuItem<String>(
//                 value: 'account2',
//                 child: Text('Account 2'),
//               ),
//               PopupMenuItem<String>(
//                 value: 'calendar1',
//                 child: Text('Calendar 1'),
//               ),
//               PopupMenuItem<String>(
//                 value: 'calendar2',
//                 child: Text('Calendar 2'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16.0),
//           children: [
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Subject'),
//               onSaved: (value) => _subject = value ?? '',
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'Date'),
//                     readOnly: true,
//                     onTap: () async {
//                       final pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate ?? DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2101),
//                       );
//                       if (pickedDate != null) {
//                         setState(() {
//                           _selectedDate = pickedDate;
//                         });
//                       }
//                     },
//                     controller: TextEditingController(
//                       text: _selectedDate?.toString().split(' ')[0] ?? '',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'From'),
//                     readOnly: true,
//                     onTap: () async {
//                       final pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: _startTime ?? TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _startTime = pickedTime;
//                         });
//                       }
//                     },
//                     controller: TextEditingController(
//                       text: _startTime?.format(context) ?? '',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     decoration: InputDecoration(labelText: 'To'),
//                     readOnly: true,
//                     onTap: () async {
//                       final pickedTime = await showTimePicker(
//                         context: context,
//                         initialTime: _endTime ?? TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           _endTime = pickedTime;
//                         });
//                       }
//                     },
//                     controller: TextEditingController(
//                       text: _endTime?.format(context) ?? '',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.view_day),
//                   onPressed: () {
//                     setState(() {
//                       _isAllDay = !_isAllDay;
//                     });
//                   },
//                   color: _isAllDay ? Colors.blue : Colors.grey,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.repeat),
//                   onPressed: () {
//                     setState(() {
//                       _isRecurring = !_isRecurring;
//                     });
//                   },
//                   color: _isRecurring ? Colors.blue : Colors.grey,
//                 ),
//                 Text(_recurrencePattern),
//               ],
//             ),
//             Wrap(
//               spacing: 8.0,
//               children: _categories.map((String category) {
//                 return ChoiceChip(
//                   label: Text(category),
//                   selected: _category == category,
//                   onSelected: (bool selected) {
//                     setState(() {
//                       _category = selected ? category : '';
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'List participants'),
//               onChanged: (value) {
//                 setState(() {
//                   _participants =
//                       value.split(',').map((e) => e.trim()).toList();
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Description'),
//               maxLines: 5,
//               onChanged: (value) => _description = value,
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   child: Text('Cancel'),
//                   onPressed: () {
//                     // Handle cancel action
//                   },
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   child: Text('Save'),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();
//                       // Handle save action
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
