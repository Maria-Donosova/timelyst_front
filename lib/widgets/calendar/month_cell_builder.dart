import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

double? width, cellWidth;

Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
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
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10.0),
                child: Text(
                  details.date.day.toString(),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              // EventOfDayW(
              //   eventOfDay: "Event",
              // ),
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
                    // CircleAvatar(
                    //   backgroundColor: Colors.green,
                    //   radius: 5,
                    // )
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
