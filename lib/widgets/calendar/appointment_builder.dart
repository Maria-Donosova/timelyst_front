import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../shared/categories.dart';

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;

  final selectedCategory = 'Personal';
  final categoryColor = catColor(selectedCategory);

  return Container(
    width: calendarAppointmentDetails.bounds.width,
    height: calendarAppointmentDetails.bounds.height,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Card(
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: categoryColor,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text(
                            'Title',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: calendarAppointmentDetails.bounds.width,
          child: Align(
            alignment: Alignment(-0.989, -1),
            child: CircleAvatar(
              backgroundColor: categoryColor,
              radius: 3.5,
            ),
          ),
        ),
      ],
    ),
  );

  // Column(
  //   children: [
  //     Container(
  //         width: calendarAppointmentDetails.bounds.width,
  //         height: calendarAppointmentDetails.bounds.height / 2,
  //         color: appointment.color,
  //         child: Center(
  //           child: Icon(
  //             Icons.group,
  //             color: Colors.black,
  //           ),
  //         )),
  //     Container(
  //       width: calendarAppointmentDetails.bounds.width,
  //       height: calendarAppointmentDetails.bounds.height / 2,
  //       color: appointment.color,
  //       child: Text(
  //         appointment.subject +
  //             DateFormat(' (hh:mm a').format(appointment.startTime) +
  //             '-' +
  //             DateFormat('hh:mm a)').format(appointment.endTime),
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontSize: 10),
  //       ),
  //     )
  //   ],
  // );
}
