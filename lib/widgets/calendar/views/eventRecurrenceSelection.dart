import 'package:flutter/material.dart';

class RecurrenceSelectionWidget extends StatefulWidget {
  final String initialRecurrence;
  final List<String> initialSelectedDays;

  const RecurrenceSelectionWidget({
    Key? key,
    required this.initialRecurrence,
    required this.initialSelectedDays,
  }) : super(key: key);

  @override
  State<RecurrenceSelectionWidget> createState() =>
      _RecurrenceSelectionWidgetState();
}

class _RecurrenceSelectionWidgetState extends State<RecurrenceSelectionWidget> {
  late String _recurrence;
  late List<String> _selectedDays;

  @override
  void initState() {
    super.initState();
    _recurrence = widget.initialRecurrence;
    _selectedDays = List.from(widget.initialSelectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Recurrence'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('None'),
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
              title: const Text('Daily'),
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
              title: const Text('Weekly'),
              value: 'Weekly',
              groupValue: _recurrence,
              onChanged: (value) {
                setState(() {
                  _recurrence = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Yearly'),
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
              Column(
                children: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ].map((day) {
                  return CheckboxListTile(
                    title: Text(day),
                    value: _selectedDays.contains(day),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'recurrence': _recurrence,
              'selectedDays': _selectedDays,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Helper function to show the recurrence selection dialog
Future<Map<String, dynamic>?> showRecurrenceSelectionDialog(
    BuildContext context,
    {String initialRecurrence = 'None',
    List<String> initialSelectedDays = const []}) async {
  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return RecurrenceSelectionWidget(
        initialRecurrence: initialRecurrence,
        initialSelectedDays: initialSelectedDays,
      );
    },
  );
}
