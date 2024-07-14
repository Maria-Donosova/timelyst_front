import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/categories.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    //super.key,
    required String? dateText,
    required String? startTimeText,
    required String? endTimeText,
  })  : _dateText = dateText,
        _startTimeText = startTimeText,
        _endTimeText = endTimeText;

  final String? _dateText;
  final String? _startTimeText;
  final String? _endTimeText;

  @override
  State<NewAppointment> createState() => NewAppointmentState();
}

class NewAppointmentState extends State<NewAppointment> {
  final _appForm = GlobalKey<FormState>();
  late TextEditingController _eventDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;

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
              width: 500,
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
