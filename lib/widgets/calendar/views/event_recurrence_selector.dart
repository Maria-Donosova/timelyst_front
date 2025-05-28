import 'package:flutter/material.dart';

class EventRecurrenceSelector extends StatelessWidget {
  final bool isRecurring;
  final String recurrence;
  final VoidCallback onRecurrenceSelected;

  const EventRecurrenceSelector({
    Key? key,
    required this.isRecurring,
    required this.recurrence,
    required this.onRecurrenceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.event_repeat),
          color: isRecurring
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          onPressed: onRecurrenceSelected,
        ),
        Text(recurrence),
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// class RecurrenceSelectionWidget extends StatefulWidget {
//   final String initialRecurrence;
//   final List<String> initialSelectedDays;

//   const RecurrenceSelectionWidget({
//     Key? key,
//     required this.initialRecurrence,
//     required this.initialSelectedDays,
//   }) : super(key: key);

//   @override
//   State<RecurrenceSelectionWidget> createState() =>
//       _RecurrenceSelectionWidgetState();
// }

// class _RecurrenceSelectionWidgetState extends State<RecurrenceSelectionWidget> {
//   late String _recurrence;
//   late List<String> _selectedDays;

//   @override
//   void initState() {
//     super.initState();
//     _recurrence = widget.initialRecurrence;
//     _selectedDays = List.from(widget.initialSelectedDays);
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Enterring select the recurrence widget');
//     print('Recurrence: $_recurrence');
//     return AlertDialog(
//       actions: [
//         TextButton(
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.secondary),
//           child: Text('Delete',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onPrimary,
//               )),
//           onPressed: () {
//             Navigator.of(context).pop(null);
//           },
//         ),
//         TextButton(
//           style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.secondary),
//           child: Text('Save',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onPrimary,
//               )),
//           onPressed: () {
//             Navigator.of(context).pop({
//               'recurrence': _recurrence,
//               'selectedDays': _selectedDays,
//             });
//           },
//         )
//       ],
//       title: const Text('Select Recurrence'),
//       content: Column(mainAxisSize: MainAxisSize.min, children: [
//         RadioListTile<String>(
//           activeColor: Theme.of(context).colorScheme.onPrimary,
//           title: Text('None'),
//           value: 'None',
//           groupValue: _recurrence,
//           onChanged: (value) {
//             setState(() {
//               _recurrence = value!;
//               _selectedDays.clear();
//             });
//           },
//         ),
//         RadioListTile<String>(
//           title: Text('Daily'),
//           value: 'Daily',
//           groupValue: _recurrence,
//           onChanged: (value) {
//             setState(() {
//               _recurrence = value!;
//               _selectedDays.clear();
//             });
//           },
//         ),
//         RadioListTile<String>(
//           title: Text('Weekly'),
//           value: 'Weekly',
//           groupValue: _recurrence,
//           onChanged: (value) {
//             setState(() {
//               _recurrence = value!;
//             });
//           },
//         ),
//         RadioListTile<String>(
//           title: Text('Yearly'),
//           value: 'Yearly',
//           groupValue: _recurrence,
//           onChanged: (value) {
//             setState(() {
//               _recurrence = value!;
//               _selectedDays.clear();
//             });
//           },
//         ),
//         if (_recurrence == 'Weekly')
//           Column(children: [
//             CheckboxListTile(
//               title: Text('Monday'),
//               value: _selectedDays.contains('Monday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Monday');
//                   } else {
//                     _selectedDays.remove('Monday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Tuesday'),
//               value: _selectedDays.contains('Tuesday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Tuesday');
//                   } else {
//                     _selectedDays.remove('Tuesday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Wednesday'),
//               value: _selectedDays.contains('Wednesday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Wednesday');
//                   } else {
//                     _selectedDays.remove('Wednesday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Thursday'),
//               value: _selectedDays.contains('Thursday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Thursday');
//                   } else {
//                     _selectedDays.remove('Thursday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Friday'),
//               value: _selectedDays.contains('Friday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Friday');
//                   } else {
//                     _selectedDays.remove('Friday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Saturday'),
//               value: _selectedDays.contains('Saturday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Saturday');
//                   } else {
//                     _selectedDays.remove('Saturday');
//                   }
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: Text('Sunday'),
//               value: _selectedDays.contains('Sunday'),
//               onChanged: (bool? value) {
//                 setState(() {
//                   if (value == true) {
//                     _selectedDays.add('Sunday');
//                   } else {
//                     _selectedDays.remove('Sunday');
//                   }
//                 });
//               },
//             )
//           ])
//       ]),
//     );
//   }
// }

// // Helper function to show the recurrence selection dialog
// Future<Map<String, dynamic>?> showRecurrenceSelectionDialog(
//     BuildContext context,
//     {String initialRecurrence = 'None',
//     List<String> initialSelectedDays = const []}) async {
//   return await showDialog<Map<String, dynamic>>(
//     context: context,
//     builder: (BuildContext context) {
//       return RecurrenceSelectionWidget(
//         initialRecurrence: initialRecurrence,
//         initialSelectedDays: initialSelectedDays,
//       );
//     },
//   );
// }
