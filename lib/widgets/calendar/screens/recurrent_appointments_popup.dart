//widget that displays a pop up dialog that allows user to set the recurrent pattern

import 'package:flutter/material.dart';

class RecurrentAppointmentsPopUp extends StatefulWidget {
  RecurrentAppointmentsPopUp(
      {required this.recurrenceRule,
      required this.onRecurrenceRuleChange,
      required this.onRecurrenceRuleClose});

  String recurrenceRule;
  ValueChanged<String> onRecurrenceRuleChange;
  VoidCallback onRecurrenceRuleClose;

  @override
  _RecurrentAppointmentsPopUpState createState() =>
      _RecurrentAppointmentsPopUpState();
}

class _RecurrentAppointmentsPopUpState
    extends State<RecurrentAppointmentsPopUp> {
  //late TextEditingController _eventRecurrenceRule;
  late String _recurrence;
  late List<String> _selectedDays;
  bool _isRecurring = false;

  @override
  void initState() {
    //_eventRecurrenceRule = TextEditingController();
    _recurrence = 'None';
    _selectedDays = <String>[];
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary),
            child: Text('Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary),
            child: Text('Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
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
  }
}

//  if (selectedRecurrenceRule != null) {
//       setState(() {
//         _eventRecurrenceRule.text = selectedRecurrenceRule;
//       });
//     }

// AlertDialog(
//   title: const Text('Recurrence Pattern'),
//   content: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: <Widget>[
//       TextField(
//         controller: TextEditingController(text: widget.recurrenceRule),
//         onChanged: widget.onRecurrenceRuleChange,
//         maxLines: 5,
//         decoration: const InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: 'Recurrence Rule',
//         ),
//       ),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           TextButton(
//             onPressed: widget.onRecurrenceRuleClose,
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     ],
//   ),
// );
