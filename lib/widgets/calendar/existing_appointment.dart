import 'package:flutter/material.dart';

class ExistingAppointment extends StatelessWidget {
  const ExistingAppointment({
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
    return AlertDialog(
      title: Container(child: new Text('$_subjectText')),
      content: Container(
        height: 80,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '$_dateText',
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
                Text(_timeDetails!,
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
              ],
            )
          ],
        ),
      ),
      actions: <Widget>[
        new TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: new Text('Save')),
      ],
    );
  }
}
