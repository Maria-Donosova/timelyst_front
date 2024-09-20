//function returns a dialog and displays the external profiles and calendars to which the event can be added
//the user can select the external profile or calendar to which the event should be added

import 'package:flutter/material.dart';

class CalendarsDetailsPopUp extends StatefulWidget {
  CalendarsDetailsPopUp(
      {required this.eventSourceCalendar,
      required this.onEventSourceCalendarChange,
      required this.onEventSourceCalendarClose});

  String eventSourceCalendar;
  ValueChanged<String> onEventSourceCalendarChange;
  VoidCallback onEventSourceCalendarClose;

  @override
  _CalendarsDetailsPopUpState createState() => _CalendarsDetailsPopUpState();
}

class _CalendarsDetailsPopUpState extends State<CalendarsDetailsPopUp> {
  late String _eventSourceCalendar;
  bool isChecked = false;

  @override
  void initState() {
    _eventSourceCalendar = widget.eventSourceCalendar;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title:
            Text('Accounts', style: Theme.of(context).textTheme.displaySmall),
        content: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(''),
        ])));
  }
}
  
  
  
  
  // Future<void> _selectSourceCalendar(BuildContext context) async {
  //   final selectedSourceCalendar = await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Accounts',
  //               style: Theme.of(context).textTheme.displaySmall),
  //           content: SingleChildScrollView(
  //             child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text('test@gmail.com',
  //                       style: Theme.of(context).textTheme.bodyLarge),
  //                   Padding(
  //                     padding: const EdgeInsets.only(bottom: 10.0),
  //                     child: Row(
  //                       children: [
  //                         CheckboxMenuButton(
  //                             value: isChecked,
  //                             onChanged: (bool? value) {
  //                               setState(() {
  //                                 isChecked = value!;
  //                               });
  //                             },
  //                             child: Text('US Holidays')),
  //                         CheckboxMenuButton(
  //                             value: isChecked,
  //                             onChanged: (bool? value) {
  //                               setState(() {
  //                                 isChecked = value!;
  //                               });
  //                             },
  //                             child: Text('Russian Holidays')),
  //                         CheckboxMenuButton(
  //                             value: isChecked,
  //                             onChanged: (bool? value) {
  //                               setState(() {
  //                                 isChecked = value!;
  //                               });
  //                             },
  //                             child: Text('Birthdays')),
  //                       ],
  //                     ),
  //                   ),
  //                   Text('tryitout@gmail.com',
  //                       style: Theme.of(context).textTheme.bodyLarge),
  //                   CheckboxMenuButton(
  //                       value: isChecked,
  //                       onChanged: (bool? value) {
  //                         setState(() {
  //                           isChecked = value!;
  //                         });
  //                       },
  //                       child: Text('Holidays')),
  //                   Text('thisisit@icloud.com',
  //                       style: Theme.of(context).textTheme.bodyLarge),
  //                   CheckboxMenuButton(
  //                       value: isChecked,
  //                       onChanged: (bool? value) {
  //                         setState(() {
  //                           isChecked = value!;
  //                         });
  //                       },
  //                       child: Text('Holidays'))
  //                 ]),
  //           ),
  //         );
  //       });

  //   if (selectedSourceCalendar != null) {
  //     setState(() {
  //       _eventSourceCalendar.text = selectedSourceCalendar;
  //     });
  //   }
  // }