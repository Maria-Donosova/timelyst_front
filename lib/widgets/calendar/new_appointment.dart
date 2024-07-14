import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/categories.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    super.key,
    //required String? id,
    required String? eventTitle,
    required String? eventCategory,
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
        _eventCategory = eventCategory,
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
  final String? _eventCategory;
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
  final _appForm = GlobalKey<FormState>();
  late TextEditingController _eventDateController;
  late TextEditingController _eventCategoryController;
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
    final _eventSubjController = TextEditingController();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Form(
      //key: _appForm,
      child: SizedBox(
        width: 500,
        height: height,
        child: Column(
          children: <Widget>[
            SizedBox(
              width: width * 0.8,
              child: TextFormField(
                autocorrect: true,
                controller: _eventSubjController,
                style: Theme.of(context).textTheme.bodyMedium,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 160,
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
                  width: 100,
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
                  width: 100,
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
              ],
            ),
            SizedBox(
              width: width,
              child: DropdownButton<String>(
                  hint: Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 14,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      child: Text(category),
                      value: category,
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      // Handle category selection
                    });
                    Navigator.of(context).pop();
                  }),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.view_day_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.queue_rounded)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.question_mark_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.holiday_village_outlined)),
            ]),
            SizedBox(
              width: 500,
              child: TextFormField(
                autocorrect: true,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
              ),
            ),
            SizedBox(
              width: width * 0.8,
              child: TextFormField(
                autocorrect: true,
                controller: _eventOrganizer,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Attendees',
                  labelStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.calendar_month)),
              IconButton(onPressed: () {}, icon: Icon(Icons.calendar_today)),
              IconButton(onPressed: () {}, icon: Icon(Icons.person_2_outlined)),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 30),
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
