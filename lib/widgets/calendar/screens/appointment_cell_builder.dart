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
  // Get the first appointment from the list of appointments
  final CustomAppointment customAppointment =
      calendarAppointmentDetails.appointments.first;

  // Check if the appointment has a single day duration
  // If the end time and start time have the same year, month, and day, it's a single day duration
  bool isSameDate = customAppointment.startTime.year ==
          customAppointment.endTime.year &&
      customAppointment.startTime.month == customAppointment.endTime.month &&
      customAppointment.startTime.day == customAppointment.endTime.day;

  // Get the width of the screen
  final width = MediaQuery.of(context).size.width;

  /**
   * If the appointment has a single day duration, return a Card with the appointment details
   */
  if (isSameDate) {
    return Container(
      // Set the width of the Container to the width of the screen
      width: width,
      // Set the height of the Container to the height of the appointment in the calendar
      height: calendarAppointmentDetails.bounds.height,
      child: Card(
        // Add a shadow effect to the Card
        elevation: 4,
        child: InkWell(
          // Change the color of the splash effect on tap
          splashColor: Colors.blueGrey.withAlpha(30),
          child: Stack(children: [
            // Add some padding to the stack
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                // Display the appointment subject
                customAppointment.subject,
                // Style the text with the bodyLarge TextStyle
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Add a CircleAvatar to the stack with a single pixel radius
            SizedBox(
              child: Align(
                // Position the CircleAvatar at the top-left of the stack
                alignment: Alignment(-1.005, -1.05),
                child: CircleAvatar(
                  // Set the background color of the CircleAvatar to the category color
                  backgroundColor: catColor(customAppointment.catTitle),
                  // Set the radius of the CircleAvatar
                  radius: 3.5,
                ),
              ),
            ),
            // Add a Container to the stack with some padding
            Container(
              padding: const EdgeInsets.all(10.0),
              // Add a decoration to the Container
              decoration: BoxDecoration(
                // Add a border to the Container
                border: Border(
                  left: BorderSide(
                    // Add a border to the left of the Container with the category color
                    color: catColor(customAppointment.catTitle),
                    // Set the width and style of the border
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                // Set the shape of the Container to a rectangle
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
      // Set the width of the Container to the width of the screen
      width: width,
      // Set the color of the Container to the category color
      color: catColor(customAppointment.catTitle),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          // Display the appointment subject
          customAppointment.subject,
          // Style the text with a TextStyle
          style: TextStyle(
            // Set the text color to the primary color of the theme
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
