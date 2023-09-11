import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event_of_day.dart';

double? width, cellWidth;

Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
  var length = details.appointments.length;
  final width = MediaQuery.of(context).size.width;
  return Container(
    child: Card(
      elevation: 4,
      child: InkWell(
        splashColor: Colors.blueGrey.withAlpha(30),
        onTap: () {
          print('Card tapped.');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 6.0),
              child: Text(
                details.date.day.toString(),
                textAlign: TextAlign.left,
              ),
            ),
            EventOfDayW(),
            Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$length' + ' Event(s)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 5,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
