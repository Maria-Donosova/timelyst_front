import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '../models/custom_appointment.dart';

/**
 * Method to build the UI for a single appointment.
 * It determines whether the appointment has a single day duration or a multi-day duration.
 * 
 * If the appointment has a single day duration, it displays a Card with the appointment details inside it.
 * If the appointment has a multi-day duration, it displays a colored rectangle with the appointment title on it.
 * 
 * @param context The context of the current widget.
 * @param calendarAppointmentDetails Details related to the appointment in the calendar.
 */
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  try {
    // Get the first appointment from the list of appointments
    final CustomAppointment customAppointment =
        calendarAppointmentDetails.appointments.first;

    // Check if the appointment has a single day duration
    // If the end time and start time have the same year, month, and day, it's a single day duration

    bool isSameDay = customAppointment.startTime.year ==
            customAppointment.endTime.year &&
        customAppointment.startTime.month == customAppointment.endTime.month;

    final width = MediaQuery.of(context).size.width;

    /**
     * If the appointment has a single day duration, return a Card with the appointment details
     */
    if (isSameDay && customAppointment.isAllDay == false) {
      return Container(
        width: width,
        // Set the height of the Container to the height of the appointment in the calendar
        height: calendarAppointmentDetails.bounds.height,
        child: Card(
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  // Display the appointment subject
                  customAppointment.subject,

                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SizedBox(
                child: Align(
                  // Position the CircleAvatar at the top-left of the stack
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
    }
    /**
     * If the appointment has a multi-day duration, return a colored rectangle with the appointment title
     */
    else {
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
  } catch (error) {
    return Text('Appointment cell builder error: $error');
  }
}
