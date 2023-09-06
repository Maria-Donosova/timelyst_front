import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:timelyst_flutter/widgets/calendar/week_days.dart';
import '../calendar/traffic_light.dart';
import '../calendar/event_of_day.dart';

enum _calView { day, week, month }

class CalendarHeaderW extends StatefulWidget {
  CalendarHeaderW({Key? key}) : super(key: key);

  @override
  State<CalendarHeaderW> createState() => _CalendarHeaderWState();
}

class _CalendarHeaderWState extends State<CalendarHeaderW> {
  //String? date;

  double? width, cellWidth;

  CalendarController controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = MediaQuery.of(context).size.width;
    final cellWidth = width / 16;
    final isMonth = controller.view == CalendarView.month;
    final isWeek = controller.view == CalendarView.week;
    final String _headerText = 'header';

    return Card(
      child: Column(
        children: [
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: TrafficLightW(),
                ),
                SizedBox(
                  width: mediaQuery.size.width * 0.38,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20),
                    child: Text(
                      //'Text',
                      _headerText,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                //Use back and forward controllers for the web version
                // Padding(
                //   padding: const EdgeInsets.only(left: 4, right: 4),
                //   child: SizedBox(
                //     width: mediaQuery.size.width * 0.025,
                //     child: IconButton(
                //       iconSize: 18,
                //       color: Colors.grey[800],
                //       icon: const Icon(Icons.arrow_back),
                //       onPressed: () {
                //         //_controller.backward!();
                //       },
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 6, right: 4),
                //   child: SizedBox(
                //     width: mediaQuery.size.width * 0.025,
                //     child: IconButton(
                //       iconSize: 18,
                //       color: Colors.grey[800],
                //       icon: const Icon(Icons.arrow_forward),
                //       onPressed: () {
                //         //_controller.forward!();
                //       },
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 10),
                  child: SizedBox(
                    width: mediaQuery.size.width * 0.03,
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[800],
                      ),
                      iconSize: 20,
                      elevation: 8,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<_calView>>[
                        const PopupMenuItem<_calView>(
                          value: _calView.day,
                          child: Text('Day'),
                        ),
                        const PopupMenuItem<_calView>(
                          value: _calView.week,
                          child: Text('Week'),
                        ),
                        const PopupMenuItem<_calView>(
                          value: _calView.month,
                          child: Text('Month'),
                        ),
                      ],
                      onSelected: (value) {
                        setState(
                          () {
                            if (value == _calView.day) {
                              controller.view = CalendarView.day;
                            } else if (value == _calView.week) {
                              controller.view = CalendarView.week;
                            } else if (value == _calView.month) {
                              controller.view = CalendarView.month;
                            }
                            ;
                          },
                        );
                      },
                    ),
                    //},
                  ),
                ),
                //),
              ],
            ),
            Container(
              width: width,
              color: const Color.fromRGBO(238, 243, 246, 1.0),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: EventOfDayW(),
              ),
            ),
            isMonth
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: WeekDaysW(
                        cellWidth: cellWidth,
                        viewHeaderText6: 'Sun',
                        viewHeaderText: 'Mon',
                        viewHeaderText1: 'Tue',
                        viewHeaderText2: 'Wed',
                        viewHeaderText3: 'Thu',
                        viewHeaderText4: 'Fri',
                        viewHeaderText5: 'Sat'),
                  )
                : isWeek
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: WeekDaysW(
                            cellWidth: 7,
                            viewHeaderText6: 'S',
                            viewHeaderText: 'M',
                            viewHeaderText1: 'T',
                            viewHeaderText2: 'W',
                            viewHeaderText3: 'T',
                            viewHeaderText4: 'F',
                            viewHeaderText5: 'S'),
                      )
                    : Container(),
          ]),
        ],
      ),
      //],
      //),
    );
  }
}
