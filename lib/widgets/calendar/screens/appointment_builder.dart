import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '/models/custom_appointment.dart';

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final CustomAppointment customAppointment =
      calendarAppointmentDetails.appointments.first;

  bool isSameDate = customAppointment.startTime.year ==
          customAppointment.endTime.year &&
      customAppointment.startTime.month == customAppointment.endTime.month &&
      customAppointment.startTime.day == customAppointment.endTime.day;

  final width = MediaQuery.of(context).size.width;

  if (isSameDate) {
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
                customAppointment.subject,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              child: Align(
                alignment: Alignment(-1.005, -1.05),
                child: CircleAvatar(
                  backgroundColor: catColor(customAppointment.catTitle),
                  radius: 3.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: catColor(customAppointment.catTitle),
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ]),
        ),
      ),
    );
  } else
    return Container(
      width: width,
      color: catColor(customAppointment.catTitle),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          customAppointment.subject,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
}
