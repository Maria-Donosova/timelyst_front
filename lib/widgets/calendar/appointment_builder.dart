import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/calendar/calendar.dart';

// import '../../models/user_calendar.dart';
// import '../../models/user_profile.dart';

import '../shared/categories.dart';

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  final categoryColor = appointment.color;

  //final selectedCategory = 'Friends';
  //final categoryColor = catColor(selectedCategory);

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
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              child: Align(
                alignment: Alignment(-1.005, -1.05),
                child: CircleAvatar(
                  backgroundColor: appointment.color,
                  radius: 3.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: appointment.color,
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
