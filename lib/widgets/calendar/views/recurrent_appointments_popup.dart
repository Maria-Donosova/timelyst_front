//widget that displays a pop up dialog that allows user to set the recurrent pattern

import 'package:flutter/material.dart';

class RecurrentAppointmentsPopUp extends StatefulWidget {
  RecurrentAppointmentsPopUp(
      {required this.recurrenceRule,
      //this.onRecurrenceRuleChange,
      //this.onRecurrenceRuleClose,
      this.isRecurring = false,
      this.selectedDays = const <String>[]});

  String recurrenceRule;
  late ValueChanged<String> onRecurrenceRuleChange;
  late VoidCallback onRecurrenceRuleClose;
  bool isRecurring;
  List<String> selectedDays;

  @override
  _RecurrentAppointmentsPopUpState createState() =>
      _RecurrentAppointmentsPopUpState();
}

class _RecurrentAppointmentsPopUpState
    extends State<RecurrentAppointmentsPopUp> {
  //late TextEditingController _eventRecurrenceRule;
  //late String _recurrence;
  //late List<String> _selectedDays;
  //bool _isRecurring = false;

  @override
  void initState() {
    //_eventRecurrenceRule = TextEditingController();
    widget.recurrenceRule = 'None';
    widget.selectedDays = <String>[];
    super.initState();
  }

  void _changeRecurringColor() {
    if (widget.recurrenceRule != 'None') {
      setState(() {
        widget.isRecurring = true;
      });
    }
  }

  void _changeRecurringPattern() {
    if (widget.recurrenceRule != 'None') {
      setState(() {
        widget.recurrenceRule = widget.recurrenceRule;
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
              //widget.onRecurrenceRuleChange(_recurrence);

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
            groupValue: widget.recurrenceRule,
            onChanged: (value) {
              setState(() {
                widget.recurrenceRule = value!;
                widget.selectedDays.clear();
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Daily'),
            value: 'Daily',
            groupValue: widget.recurrenceRule,
            onChanged: (value) {
              setState(() {
                widget.recurrenceRule = value!;
                widget.selectedDays.clear();
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Weekly'),
            value: 'Weekly',
            groupValue: widget.recurrenceRule,
            onChanged: (value) {
              setState(() {
                widget.recurrenceRule = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('Yearly'),
            value: 'Yearly',
            groupValue: widget.recurrenceRule,
            onChanged: (value) {
              setState(() {
                widget.recurrenceRule = value!;
                widget.selectedDays.clear();
              });
            },
          ),
          if (widget.recurrenceRule == 'Weekly')
            Column(children: [
              CheckboxListTile(
                title: Text('Monday'),
                value: widget.selectedDays.contains('Monday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Monday');
                    } else {
                      widget.selectedDays.remove('Monday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Tuesday'),
                value: widget.selectedDays.contains('Tuesday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Tuesday');
                    } else {
                      widget.selectedDays.remove('Tuesday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Wednesday'),
                value: widget.selectedDays.contains('Wednesday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Wednesday');
                    } else {
                      widget.selectedDays.remove('Wednesday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Thursday'),
                value: widget.selectedDays.contains('Thursday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Thursday');
                    } else {
                      widget.selectedDays.remove('Thursday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Friday'),
                value: widget.selectedDays.contains('Friday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Friday');
                    } else {
                      widget.selectedDays.remove('Friday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Saturday'),
                value: widget.selectedDays.contains('Saturday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Saturday');
                    } else {
                      widget.selectedDays.remove('Saturday');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Sunday'),
                value: widget.selectedDays.contains('Sunday'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      widget.selectedDays.add('Sunday');
                    } else {
                      widget.selectedDays.remove('Sunday');
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
