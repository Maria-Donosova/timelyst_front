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

    // Helper function to get the appropriate widget based on calendar source
    Widget _getCalendarSourceWidget(CustomAppointment appointment,
        {double size = 14, required Color color}) {
      // Debug logging to understand what data we have
      print('🔍 [Icon Debug] Checking appointment: "${appointment.title}"');
      print('  - source: ${appointment.source}');
      print('  - googleEventId: ${appointment.googleEventId}');
      print('  - microsoftEventId: ${appointment.microsoftEventId}');
      print('  - appleEventId: ${appointment.appleEventId}');
      print('  - sourceCalendar: ${appointment.sourceCalendar}');
      print('  - calendarId: ${appointment.calendarId}');
      print('  - createdBy: ${appointment.createdBy}');
      print('  - userCalendars: ${appointment.userCalendars}');

      // First check the source map which should contain the most reliable information
      if (appointment.source != null && appointment.source!.isNotEmpty) {
        final sourceType =
            appointment.source!['type']?.toString().toLowerCase() ?? '';
        final sourceName =
            appointment.source!['name']?.toString().toLowerCase() ?? '';

        print('  - sourceType: "$sourceType"');
        print('  - sourceName: "$sourceName"');

        if (sourceType.contains('google') || sourceName.contains('google')) {
          print('  ✅ Returning Google icon (mail_outline)');
          return Icon(Icons.mail_outline, size: size, color: color);
        } else if (sourceType.contains('microsoft') ||
            sourceType.contains('outlook') ||
            sourceName.contains('microsoft') ||
            sourceName.contains('outlook')) {
          print('  ✅ Returning Microsoft icon (window_outlined)');
          return Icon(Icons.window_outlined, size: size, color: color);
        } else if (sourceType.contains('apple') ||
            sourceType.contains('icloud') ||
            sourceName.contains('apple') ||
            sourceName.contains('icloud')) {
          print('  ✅ Returning Apple icon (apple)');
          return Icon(Icons.apple, size: size, color: color);
        }
      }

      // Check for specific calendar source IDs
      if (appointment.googleEventId != null &&
          appointment.googleEventId!.isNotEmpty) {
        print('  ✅ Returning Google icon (mail_outline) - googleEventId found');
        return Icon(Icons.mail_outline, size: size, color: color);
      } else if (appointment.microsoftEventId != null &&
          appointment.microsoftEventId!.isNotEmpty) {
        print(
            '  ✅ Returning Microsoft icon (window_outlined) - microsoftEventId found');
        return Icon(Icons.window_outlined, size: size, color: color);
      } else if (appointment.appleEventId != null &&
          appointment.appleEventId!.isNotEmpty) {
        print(
            '  ✅ Returning Apple icon (apple) - appleEventId found: ${appointment.appleEventId}');
        return Icon(Icons.apple, size: size, color: color);
      }

      // Check sourceCalendar field for calendar name patterns
      if (appointment.sourceCalendar != null &&
          appointment.sourceCalendar!.isNotEmpty) {
        final sourceCalendarLower = appointment.sourceCalendar!.toLowerCase();
        print('  - sourceCalendarLower: "$sourceCalendarLower"');

        if (sourceCalendarLower.contains('google')) {
          print(
              '  ✅ Returning Google icon (mail_outline) - sourceCalendar contains google');
          return Icon(Icons.mail_outline, size: size, color: color);
        } else if (sourceCalendarLower.contains('microsoft') ||
            sourceCalendarLower.contains('outlook')) {
          print(
              '  ✅ Returning Microsoft icon (window_outlined) - sourceCalendar contains microsoft/outlook');
          return Icon(Icons.window_outlined, size: size, color: color);
        } else if (sourceCalendarLower.contains('apple') ||
            sourceCalendarLower.contains('icloud') ||
            sourceCalendarLower.contains('caldav')) {
          print(
              '  ✅ Returning Apple icon (apple) - sourceCalendar contains apple/icloud/caldav');
          return Icon(Icons.apple, size: size, color: color);
        }
      }

      // Check calendarId field as well
      if (appointment.calendarId != null &&
          appointment.calendarId!.isNotEmpty) {
        final calendarIdLower = appointment.calendarId!.toLowerCase();
        print('  - calendarIdLower: "$calendarIdLower"');

        if (calendarIdLower.contains('google')) {
          print(
              '  ✅ Returning Google icon (mail_outline) - calendarId contains google');
          return Icon(Icons.mail_outline, size: size, color: color);
        } else if (calendarIdLower.contains('microsoft') ||
            calendarIdLower.contains('outlook')) {
          print(
              '  ✅ Returning Microsoft icon (window_outlined) - calendarId contains microsoft/outlook');
          return Icon(Icons.window_outlined, size: size, color: color);
        } else if (calendarIdLower.contains('apple') ||
            calendarIdLower.contains('icloud') ||
            calendarIdLower.contains('caldav')) {
          print(
              '  ✅ Returning Apple icon (apple) - calendarId contains apple/icloud/caldav');
          return Icon(Icons.apple, size: size, color: color);
        }
      }

      // Check userCalendars field as it might contain calendar names
      if (appointment.userCalendars.isNotEmpty) {
        for (final calendar in appointment.userCalendars) {
          final calendarLower = calendar.toLowerCase();
          print('  - Checking userCalendar: "$calendarLower"');

          if (calendarLower.contains('google')) {
            print(
                '  ✅ Returning Google icon (mail_outline) - userCalendars contains google');
            return Icon(Icons.mail_outline, size: size, color: color);
          } else if (calendarLower.contains('microsoft') ||
              calendarLower.contains('outlook')) {
            print(
                '  ✅ Returning Microsoft icon (window_outlined) - userCalendars contains microsoft/outlook');
            return Icon(Icons.window_outlined, size: size, color: color);
          } else if (calendarLower.contains('apple') ||
              calendarLower.contains('icloud') ||
              calendarLower.contains('caldav')) {
            print(
                '  ✅ Returning Apple icon (apple) - userCalendars contains apple/icloud/caldav');
            return Icon(Icons.apple, size: size, color: color);
          }
        }
      }

      // Default icon - Timelyst Logo
      print('  ❌ No source detected, returning Timelyst logo');
      return Image.asset(
        'assets/images/logos/timelyst_logo.png',
        width: size,
        height: size,
        // We don't apply color to the logo to keep its original branding,
        // unless it's specifically requested to be monochrome.
        // If it needs to match the text color, we could uncomment:
        // color: color,
      );
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
                child: _getCalendarSourceWidget(
                  customAppointment,
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
              child: _getCalendarSourceWidget(
                customAppointment,
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
