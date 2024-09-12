import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import 'package:timelyst_flutter/widgets/calendar/models/custom_appointment.dart';

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
  // Get the width of the screen
  final width = MediaQuery.of(context).size.width;
  
  // Create the UI
  return Container(
    // Set the width of the Container to the width of the screen
    width: width,
    child: Card(
      // Add a shadow effect to the Card
      elevation: 4,
      child: InkWell(
        // Change the color of the splash effect on tap
        splashColor: Colors.blueGrey.withAlpha(30),
        // Handle tap event
        onTap: () {
          print('Card tapped.');
        },
        // The content of the Card
        child: SingleChildScrollView(
          //scrolling direction
          child: Column(
            // Set the alignment of the children to the start of their parent
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the day of the month
              Padding(
                // Add some padding between the day and the parent
                padding: const EdgeInsets.only(top: 20, left: 10.0),
                child: Text(
                  // Show the day of the month
                  details.date.day.toString(),
                  // Align the text to the left
                  textAlign: TextAlign.left,
                  // Style the text with the displayLarge TextStyle
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              // Display the number of events
              Padding(
                // Add some padding between the number of events and the parent
                padding: const EdgeInsets.only(left: 10.0, right: 6.0, top: 30.0),
                child: Wrap(
                  // Set the alignment of the children to the end of their parent
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    // Display the number of events
                    Text(
                      // Number of events is equal to (length) 
                      '$length' + ' Event(s)',
                      // Align the text to the center
                      textAlign: TextAlign.center,
                      // Style the text with the bodySmall TextStyle
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    //A placeholder for CircleAvatar()
                    // CircleAvatar(
                    //   backgroundColor: Colors.green,
                    //   radius: 5,
                    // ),
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
