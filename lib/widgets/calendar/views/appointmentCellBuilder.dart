import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '../../../models/customApp.dart';
import '../../../models/calendars.dart';

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

    // Note: This appointmentBuilder is only used for day and week views in the calendar controller
    // so we can safely show source icons here. Month view uses monthCellBuilder which doesn't show icons.

    // Helper function to get the appropriate icon based on calendar source
    IconData _getCalendarSourceIcon(CustomAppointment appointment) {
      // First check the source map which should contain the most reliable information
      if (appointment.source != null && appointment.source!.isNotEmpty) {
        final sourceType =
            appointment.source!['type']?.toString().toLowerCase() ?? '';
        final sourceName =
            appointment.source!['name']?.toString().toLowerCase() ?? '';

        if (sourceType.contains('google') || sourceName.contains('google')) {
          return Icons.mail_outline;
        } else if (sourceType.contains('microsoft') ||
            sourceType.contains('outlook') ||
            sourceName.contains('microsoft') ||
            sourceName.contains('outlook')) {
          return Icons.window_outlined;
        } else if (sourceType.contains('apple') ||
            sourceType.contains('icloud') ||
            sourceName.contains('apple') ||
            sourceName.contains('icloud')) {
          return Icons.apple;
        }
      }

      // Check for specific calendar source IDs
      if (appointment.googleEventId != null &&
          appointment.googleEventId!.isNotEmpty) {
        return Icons.mail_outline;
      } else if (appointment.microsoftEventId != null &&
          appointment.microsoftEventId!.isNotEmpty) {
        return Icons.window_outlined;
      } else if (appointment.appleEventId != null &&
          appointment.appleEventId!.isNotEmpty) {
        return Icons.apple;
      }

      // Check sourceCalendar field for calendar name patterns
      if (appointment.sourceCalendar != null &&
          appointment.sourceCalendar!.isNotEmpty) {
        final sourceCalendarLower = appointment.sourceCalendar!.toLowerCase();

        if (sourceCalendarLower.contains('google')) {
          return Icons.mail_outline;
        } else if (sourceCalendarLower.contains('microsoft') ||
            sourceCalendarLower.contains('outlook')) {
          return Icons.window_outlined;
        } else if (sourceCalendarLower.contains('apple') ||
            sourceCalendarLower.contains('icloud') ||
            sourceCalendarLower.contains('caldav')) {
          return Icons.apple;
        }
      }

      // Check calendarId field as well
      if (appointment.calendarId != null &&
          appointment.calendarId!.isNotEmpty) {
        final calendarIdLower = appointment.calendarId!.toLowerCase();

        if (calendarIdLower.contains('google')) {
          return Icons.mail_outline;
        } else if (calendarIdLower.contains('microsoft') ||
            calendarIdLower.contains('outlook')) {
          return Icons.window_outlined;
        } else if (calendarIdLower.contains('apple') ||
            calendarIdLower.contains('icloud') ||
            calendarIdLower.contains('caldav')) {
          return Icons.apple;
        }
      }

      // Default icon
      return Icons.calendar_today;
    }

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
                  customAppointment.title,
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
              // Calendar source icon in bottom right corner (shown for day/week views)
              Positioned(
                right: 4,
                bottom: 4,
                child: Icon(
                  _getCalendarSourceIcon(customAppointment),
                  size: 14,
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                customAppointment.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Calendar source icon in bottom right corner for multi-day events (shown for day/week views)
            Positioned(
              right: 4,
              bottom: 4,
              child: Icon(
                _getCalendarSourceIcon(customAppointment),
                size: 14,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
  } catch (error) {
    return Text('Appointment cell builder error: $error');
  }
}
