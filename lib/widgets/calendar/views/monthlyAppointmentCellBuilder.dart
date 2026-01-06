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
  // Safe list conversion - filter for CustomAppointment only to prevent cast errors
  final List<CustomAppointment> appointments = details.appointments
      .whereType<CustomAppointment>()
      .toList();
  
  // Separate all-day and regular events
  final allDayEvents = appointments.where((app) => app.isAllDay).toList();
  final regularEvents = appointments.where((app) => !app.isAllDay).toList();

  final width = MediaQuery.of(context).size.width;

  return Container(
    width: width,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withAlpha(30), width: 0.5),
    ),
    child: InkWell(
      splashColor: Colors.blueGrey.withAlpha(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the day of the month
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8.0),
            child: Text(
              details.date.day.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          
          // Display up to 2 all-day events
          ...allDayEvents.take(2).map((event) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: catColor(event.catTitle).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: catColor(event.catTitle).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),

          // Indicator for more all-day events
          if (allDayEvents.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
              child: Text(
                '+${allDayEvents.length - 2} more',
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),
          
          const Spacer(),

          // Display dots for regular events
          if (regularEvents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                spacing: 3,
                runSpacing: 3,
                children: regularEvents.take(12).map((event) => Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: catColor(event.catTitle),
                        shape: BoxShape.circle,
                        // Add a subtle border for lighter colors
                        border: Border.all(
                          color: Colors.black.withOpacity(0.05),
                          width: 0.2,
                        ),
                      ),
                    )).toList(),
              ),
            ),
        ],
      ),
    ),
  );
}
