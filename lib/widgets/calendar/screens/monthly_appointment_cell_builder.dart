import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// The width of the widget (local variable).
double? width, cellWidth;

/**
 * Method to build the UI for a single month cell in the calendar.
 * It displays a Card with the date, number of events, and a title.
 * 
 * @param context The context of the current widget.
 * @param details Details related to the month cell in the calendar.
 */
Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
  // Get the number of appointments in the month cell
  var length = details.appointments.length;

  final width = MediaQuery.of(context).size.width;

  return Container(
    width: width,
    child: Card(
      elevation: 4,
      child: InkWell(
        splashColor: Colors.blueGrey.withAlpha(30),
        onTap: () {
          print('Card tapped.');
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the day of the month
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10.0),
                child: Text(
                  details.date.day.toString(),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              // Display the number of events
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 6.0, top: 30.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      '$length' + ' Event(s)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
