import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../shared/categories.dart';

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;

  final selectedCategory = 'Social';
  final categoryColor = catColor(selectedCategory);

  final width = MediaQuery.of(context).size.width;

  return Container(
      width: width,
      height: calendarAppointmentDetails.bounds.height,
      child: Card(
        elevation: 4,
        child: InkWell(
          splashColor: Colors.blueGrey.withAlpha(30),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                appointment.subject,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            SizedBox(
              child: Align(
                alignment: Alignment(-1.005, -1.05),
                child: CircleAvatar(
                  backgroundColor: categoryColor,
                  radius: 3.5,
                ),
              ),
            ),
            Container(
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
            ),
          ]),
        ),
      ));
}
