// import 'package:flutter/material.dart';

// class RecurrentAppointment extends StatefulWidget {
//   @override
//   _RecurrentAppointmentState createState() => _RecurrentAppointmentState();
// }

// class _RecurrentAppointmentState extends State<RecurrentAppointment> {
//   String _recurrence = 'None';
//   List<String> _selectedDays = [];

//   @override
//   Widget build(BuildContext context) {
//     void _showRecurrenceDialog() {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: (context, setState) {
//               return AlertDialog(
//                 title: Text('Set Recurrence'),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     RadioListTile<String>(
//                       title: Text('None'),
//                       value: 'None',
//                       groupValue: _recurrence,
//                       onChanged: (value) {
//                         setState(() {
//                           _recurrence = value!;
//                           _selectedDays.clear();
//                         });
//                       },
//                     ),
//                     RadioListTile<String>(
//                       title: Text('Daily'),
//                       value: 'Daily',
//                       groupValue: _recurrence,
//                       onChanged: (value) {
//                         setState(() {
//                           _recurrence = value!;
//                           _selectedDays.clear();
//                         });
//                       },
//                     ),
//                     RadioListTile<String>(
//                       title: Text('Weekly'),
//                       value: 'Weekly',
//                       groupValue: _recurrence,
//                       onChanged: (value) {
//                         setState(() {
//                           _recurrence = value!;
//                         });
//                       },
//                     ),
//                     RadioListTile<String>(
//                       title: Text('Yearly'),
//                       value: 'Yearly',
//                       groupValue: _recurrence,
//                       onChanged: (value) {
//                         setState(() {
//                           _recurrence = value!;
//                           _selectedDays.clear();
//                         });
//                       },
//                     ),
//                     if (_recurrence == 'Weekly')
//                       Column(
//                         children: [
//                           CheckboxListTile(
//                             title: Text('Monday'),
//                             value: _selectedDays.contains('Monday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Monday');
//                                 } else {
//                                   _selectedDays.remove('Monday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Tuesday'),
//                             value: _selectedDays.contains('Tuesday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Tuesday');
//                                 } else {
//                                   _selectedDays.remove('Tuesday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Wednesday'),
//                             value: _selectedDays.contains('Wednesday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Wednesday');
//                                 } else {
//                                   _selectedDays.remove('Wednesday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Thursday'),
//                             value: _selectedDays.contains('Thursday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Thursday');
//                                 } else {
//                                   _selectedDays.remove('Thursday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Friday'),
//                             value: _selectedDays.contains('Friday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Friday');
//                                 } else {
//                                   _selectedDays.remove('Friday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Saturday'),
//                             value: _selectedDays.contains('Saturday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Saturday');
//                                 } else {
//                                   _selectedDays.remove('Saturday');
//                                 }
//                               });
//                             },
//                           ),
//                           CheckboxListTile(
//                             title: Text('Sunday'),
//                             value: _selectedDays.contains('Sunday'),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _selectedDays.add('Sunday');
//                                 } else {
//                                   _selectedDays.remove('Sunday');
//                                 }
//                               });
//                             },
//                           ),
//                           // Add more CheckboxListTile for other days of the week
//                         ],
//                       ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     child: Text('Cancel'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   TextButton(
//                     child: Text('Save'),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       // Save the recurrence data
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     }

//     throw UnimplementedError();
//   }
// }
