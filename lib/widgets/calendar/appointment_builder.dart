import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../shared/categories.dart';

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;

  final selectedCategory = 'Social';
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
                            appointment.subject,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
}
