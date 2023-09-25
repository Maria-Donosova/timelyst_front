import 'package:flutter/material.dart';
import '../shared/categories.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    final _eventSubjController = TextEditingController();
    final _eventDateController = TextEditingController(text: widget._dateText);
    final _eventStartTimeController =
        TextEditingController(text: widget._startTimeText);
    final _eventEndTimeController =
        TextEditingController(text: widget._endTimeText);
    final width = MediaQuery.of(context).size.width;
    final hight = MediaQuery.of(context).size.height;

    return Form(
      key: _appForm,
      child: SizedBox(
        width: 500,
        height: hight,
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
                    controller: _eventStartTimeController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      labelStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.datetime,
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
                      labelText: 'End Date',
                      labelStyle: TextStyle(fontSize: 14),
                      border: InputBorder.none,
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.datetime,
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
                //value: selectedCategory,
                onChanged: (newValue) {
                  //   if (_form.currentState!.validate()) {
                  //     setState(() {
                  //       // selectedCategory = newValue;
                  //       // runMutation({
                  //       //   "task_description":
                  //       //       _taskDescriptionController.text
                  //       //           .trim(),
                  //       //   // "task_type":
                  //       //   //  _taskTypeController.text.trim(),
                  //       //   "category": _selectedCategory,
                  //       //   'userId': currUserId,
                  //       // });
                  //     });
                  //     Navigator.of(context).pop();
                  //     clearInput();
                  //   }
                },
                items: categories.map((category) {
                  return DropdownMenuItem(
                    child: Text(category),
                    value: category,
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: 500,
              child: TextFormField(
                autocorrect: true,
                //controller: _eventSubjController,
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
            // SizedBox(
            //   height: 50,
            //   width: 500,
            //   child: TextFormField(
            //     autocorrect: true,
            //     //controller: _eventSubjController,
            //     style: Theme.of(context).textTheme.bodyMedium,
            //     maxLines: null,
            //     decoration: const InputDecoration(
            //       labelText: 'Organizier',
            //       labelStyle: TextStyle(fontSize: 14),
            //       border: InputBorder.none,
            //       errorStyle: TextStyle(color: Colors.redAccent),
            //     ),
            //     textInputAction: TextInputAction.next,
            //     keyboardType: TextInputType.name,
            //     validator: (value) {
            //       if (value!.isEmpty) {
            //         return 'Please provide a value.';
            //       } else {
            //         return null;
            //       }
            //     },
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        setState(() {
                          // runMutation({
                          //   "event_subj": _eventSubjController.text.trim(),
                          //   "event_startdate":
                          //       _eventStartDateController.text.trim(),
                          //   "event_enddate": _eventEndDateController.text.trim(),
                          // });
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
