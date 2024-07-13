import 'package:flutter/material.dart';

import '../shared/categories.dart';

//create a widget to edit an existing appointment

class EditAppointment extends StatelessWidget {
  const EditAppointment({
    super.key,
    required String? subjectText,
    required String? dateText,
    required String? timeDetails,
  })  : _subjectText = subjectText,
        _dateText = dateText,
        _timeDetails = timeDetails;

  final String? _subjectText;
  final String? _dateText;
  final String? _timeDetails;

  @override
  Widget build(BuildContext context) {
    TextEditingController _titleController =
        TextEditingController(text: _subjectText);
    // TextEditingController _descriptionController =
    //     TextEditingController(text: _description);
    final selectedCategory = 'Social';
    final categoryColor = catColor(selectedCategory);

    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: Container(
        child: Text(_subjectText!),
      ),
      content: Container(
        height: 80,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  _timeDetails!,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(''),
              ],
            ),
            Row(
              children: <Widget>[
                Text(_timeDetails!.toString(),
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
              ],
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
