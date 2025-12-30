import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '../../../models/customApp.dart';

/**
 * Method to build the UI for a single month cell in the calendar.
 * It displays a summarized view with the date, first all-day event title, and number of events.
 * 
 * @param context The context of the current widget.
 * @param details Details related to the month cell in the calendar.
 */
Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
  // Get the number of appointments in the month cell
  final appointments = details.appointments;
  final length = appointments.length;

  final width = MediaQuery.of(context).size.width;

  // Find the first all-day event if any
  CustomAppointment? allDayEvent;
  for (final app in appointments) {
    if (app is CustomAppointment && app.isAllDay) {
      allDayEvent = app;
      break;
    }
  }

  return Container(
    width: width,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withAlpha(30), width: 0.5),
    ),
    child: InkWell(
      splashColor: Colors.blueGrey.withAlpha(30),
      onTap: () {
        // Taps are typically handled by SfCalendar's onTap
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the day of the month
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8.0),
            child: Text(
              details.date.day.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          // Display the all-day event title
          if (allDayEvent != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: catColor(allDayEvent.catTitle).withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                allDayEvent.title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          // Display the number of events
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$length Events',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
