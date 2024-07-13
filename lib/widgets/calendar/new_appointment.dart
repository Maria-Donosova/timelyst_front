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
  //final _appForm = GlobalKey<FormState>();
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  late TextEditingController _eventDateController;
  late TextEditingController _eventStartTimeController;
  late TextEditingController _eventEndTimeController;

  @override
  void initState() {
    super.initState();
    _eventDateController = TextEditingController(text: widget._dateText);
    _eventStartTimeController =
        TextEditingController(text: widget._startTimeText);
    _eventEndTimeController = TextEditingController(text: widget._endTimeText);
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      _selectedDate = selectedDate;
      setState(() {
        _eventDateController.text = DateFormat('MMMM d').format(selectedDate);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context, bool isStartTime) async {
    final selectedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (selectedStartTime != null) {
      setState(() {
        _eventStartTimeController.text = selectedStartTime.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context, bool isStartTime) async {
    final selectedEndTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30))),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );

    if (selectedEndTime != null && selectedEndTime != _selectedStartTime) {
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
                          print("event mutation");
                        });
                        Navigator.of(context).pop();
                      }),
                  TextButton(
                    onPressed: () {
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

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../shared/categories.dart';

// class NewAppointment extends StatefulWidget {
//   const NewAppointment({
//     super.key,
//     required String? dateText,
//     required String? startTimeText,
//     required String? endTimeText,
//   })  : _dateText = dateText,
//         _startTimeText = startTimeText,
//         _endTimeText = endTimeText;

//   final String? _dateText;
//   final String? _startTimeText;
//   final String? _endTimeText;

//   @override
//   State<NewAppointment> createState() => NewAppointmentState();
// }

// class NewAppointmentState extends State<NewAppointment> {
//   final _appForm = GlobalKey<FormState>();
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//   late final TimeOfDay? pickedStartDate;
//   late final TimeOfDay? pickedEndDate;

//   Future<String?> _selectDate(BuildContext context) async {
//     final newSelectedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2023, 1),
//       lastDate: DateTime(2101),
//     );

//     final df = new DateFormat('MMMMd');

//     if (newSelectedDate != null && newSelectedDate != _selectedDate) {
//       setState(() {
//         _selectedDate = newSelectedDate;
//       });
//     }
//     return df.format(_selectedDate);
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     pickedStartDate = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//       initialEntryMode: TimePickerEntryMode.inputOnly,
//     );
//     setState(() {
//       selectedTime = pickedStartDate!;
//     });

//     Text('Selected time: ${selectedTime.format(context)}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _eventSubjController = TextEditingController();
//     final _eventDateController = TextEditingController(text: widget._dateText);
//     final _eventStartTimeController =
//         TextEditingController(text: widget._startTimeText);
//     final _eventEndTimeController =
//         TextEditingController(text: widget._endTimeText);
//     final width = MediaQuery.of(context).size.width;
//     final hight = MediaQuery.of(context).size.height;

//     return Form(
//       key: _appForm,
//       child: SizedBox(
//         width: 500,
//         height: hight,
//         child: Column(
//           children: <Widget>[
//             SizedBox(
//               width: 500,
//               child: TextFormField(
//                 autocorrect: true,
//                 controller: _eventSubjController,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 maxLines: null,
//                 decoration: const InputDecoration(
//                   labelText: 'Subject',
//                   labelStyle: TextStyle(fontSize: 14),
//                   border: InputBorder.none,
//                   errorStyle: TextStyle(color: Colors.redAccent),
//                 ),
//                 textInputAction: TextInputAction.next,
//                 keyboardType: TextInputType.name,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please provide a value.';
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(
//                   width: 160,
//                   child: TextFormField(
//                     autocorrect: true,
//                     controller: _eventDateController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: const InputDecoration(
//                       labelText: 'Event Date',
//                       labelStyle: TextStyle(fontSize: 14),
//                       border: InputBorder.none,
//                       errorStyle: TextStyle(color: Colors.redAccent),
//                     ),
//                     textInputAction: TextInputAction.next,
//                     keyboardType: TextInputType.datetime,
//                     onTap: () async {
//                       final selectedDate = await _selectDate(context);
//                       if (selectedDate != null) {
//                         setState(() {
//                           _eventDateController.text = selectedDate;
//                         });
//                         print(_eventDateController.text);
//                       }
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: 100,
//                   child: TextFormField(
//                     autocorrect: true,
//                     controller: _eventStartTimeController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: const InputDecoration(
//                       labelText: 'Start Time',
//                       labelStyle: TextStyle(fontSize: 14),
//                       border: InputBorder.none,
//                       errorStyle: TextStyle(color: Colors.redAccent),
//                     ),
//                     textInputAction: TextInputAction.next,
//                     keyboardType: TextInputType.datetime,
//                     onTap: () => _selectTime(context),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedTime = value as TimeOfDay;
//                       });
//                     },
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please provide a value.';
//                       } else {
//                         return null;
//                       }
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   width: 100,
//                   child: TextFormField(
//                     autocorrect: true,
//                     controller: _eventEndTimeController,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                     decoration: const InputDecoration(
//                       labelText: 'End Time',
//                       labelStyle: TextStyle(fontSize: 14),
//                       border: InputBorder.none,
//                       errorStyle: TextStyle(color: Colors.redAccent),
//                     ),
//                     textInputAction: TextInputAction.next,
//                     keyboardType: TextInputType.datetime,
//                     onTap: () => _selectTime(context),
//                     validator: (value) {
//                       if (value!.isEmpty) {
//                         return 'Please provide a value.';
//                       } else {
//                         return null;
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               width: width,
//               child: DropdownButton<String>(
//                   hint: Text(
//                     'Category',
//                     style: Theme.of(context).textTheme.titleSmall,
//                   ),
//                   icon: const Icon(Icons.arrow_downward),
//                   iconSize: 14,
//                   items: categories.map((category) {
//                     return DropdownMenuItem(
//                       child: Text(category),
//                       value: category,
//                     );
//                   }).toList(),
//                   //value: selectedCategory,
//                   onChanged: (newValue) {
//                     //   if (_form.currentState!.validate()) {
//                     setState(() {
//                       //selectedCategory = newValue;

//                       // runMutation({
//                       //   "task_description":
//                       //       _taskDescriptionController.text
//                       //           .trim(),
//                       //   // "task_type":
//                       //   //  _taskTypeController.text.trim(),
//                       //   "category": _selectedCategory,
//                       //   'userId': currUserId,
//                       // });
//                     });
//                     Navigator.of(context).pop();
//                     //clearInput();
//                   }),
//             ),
//             SizedBox(
//               width: 500,
//               child: TextFormField(
//                 autocorrect: true,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 maxLines: null,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   labelStyle: TextStyle(fontSize: 14),
//                   border: InputBorder.none,
//                   errorStyle: TextStyle(color: Colors.redAccent),
//                 ),
//                 textInputAction: TextInputAction.next,
//                 keyboardType: TextInputType.name,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please provide a value.';
//                   } else {
//                     return null;
//                   }
//                 },
//               ),
//             ),
//             // SizedBox(
//             //   height: 50,
//             //   width: 500,
//             //   child: TextFormField(
//             //     autocorrect: true,
//             //     //controller: _eventSubjController,
//             //     style: Theme.of(context).textTheme.bodyMedium,
//             //     maxLines: null,
//             //     decoration: const InputDecoration(
//             //       labelText: 'Organizier',
//             //       labelStyle: TextStyle(fontSize: 14),
//             //       border: InputBorder.none,
//             //       errorStyle: TextStyle(color: Colors.redAccent),
//             //     ),
//             //     textInputAction: TextInputAction.next,
//             //     keyboardType: TextInputType.name,
//             //     validator: (value) {
//             //       if (value!.isEmpty) {
//             //         return 'Please provide a value.';
//             //       } else {
//             //         return null;
//             //       }
//             //     },
//             //   ),
//             // ),
//             Padding(
//               padding: const EdgeInsets.only(top: 30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                       child: const Text('Save'),
//                       onPressed: () {
//                         setState(() {
//                           // runMutation({
//                           //   "event_subj": _eventSubjController.text.trim(),
//                           //   "event_startdate":
//                           //       _eventStartDateController.text.trim(),
//                           //   "event_enddate": _eventEndDateController.text.trim(),
//                           // });
//                           print("event mutation");
//                         });
//                         Navigator.of(context).pop();
//                       }),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('Close'),
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
