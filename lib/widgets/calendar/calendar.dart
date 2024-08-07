import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '/widgets/calendar/week_days.dart';
// import '../shared/categories.dart';
import 'appointment_builder.dart';
import 'event_of_day.dart';
import 'month_cell_builder.dart';
import 'appointment.dart';

enum _calView { day, week, month }

class CalendarW extends StatefulWidget {
  const CalendarW({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarWState();
}

class _CalendarWState extends State<CalendarW> {
  final CalendarController _controller = CalendarController();
  String? _headerText,
      _weekStart,
      _weekEnd,
      _month,
      _subjectText,
      _startTimeText,
      _endTimeText,
      _dateText,
      _timeDetails,
      _cellDateText;
  double? width, cellWidth;

  @override
  void initState() {
    _headerText = 'header';

    _subjectText = '';
    _startTimeText = '';
    _endTimeText = '';
    _dateText = '';
    _timeDetails = '';
    _cellDateText = '';

    width = 0.0;
    cellWidth = 0.0;

    // _getEvents().then((results) {
    //   setState(() {
    //     if (results != null) {
    //       querySnapshot = results;
    //     }
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = MediaQuery.of(context).size.width;
    final cellWidth = width / 14;
    final isMonth = _controller.view == CalendarView.month;
    final isWeek = _controller.view == CalendarView.week;

    return Card(
      child: Column(
        children: [
          Column(children: [
            calendarHeader(mediaQuery, context),
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
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: WeekDaysW(
                            cellWidth: cellWidth,
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
          Expanded(
            child: SfCalendar(
                view: CalendarView.day,
                allowedViews: const [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.month
                ],
                controller: _controller,
                allowViewNavigation: false,
                headerHeight: 0,
                viewHeaderHeight: 0,
                cellBorderColor: const Color.fromRGBO(238, 243, 246, 1.0),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                showWeekNumber: true,
                weekNumberStyle: WeekNumberStyle(
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 8, color: Colors.grey[600]),
                ),
                todayHighlightColor: Color.fromRGBO(171, 178, 183, 1),
                todayTextStyle: TextStyle(color: Colors.grey[800]),
                showNavigationArrow: true,
                showCurrentTimeIndicator: true,
                monthCellBuilder: monthCellBuilder,
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                  showTrailingAndLeadingDates: false,
                ),
                appointmentBuilder: appointmentBuilder,
                allowAppointmentResize: true,
                allowDragAndDrop: true,
                //dataSource: _getCalendarDataSource(),
                onTap: _calendarTapped,
                onViewChanged: (ViewChangedDetails viewChangedDetails) {
                  if (_controller.view == CalendarView.month) {
                    _headerText = DateFormat('yMMMM')
                        .format(viewChangedDetails.visibleDates[
                            viewChangedDetails.visibleDates.length ~/ 2])
                        .toString();
                  }
                  if (_controller.view == CalendarView.week) {
                    _weekStart = DateFormat('d')
                        .format(viewChangedDetails.visibleDates[0])
                        .toString();
                    _weekEnd = DateFormat('d')
                        .format(viewChangedDetails.visibleDates[6])
                        .toString();
                    _month = DateFormat('MMMM')
                        .format(viewChangedDetails.visibleDates[0])
                        .toString();
                    _headerText =
                        _month! + ' ' + _weekStart! + ' - ' + _weekEnd!;
                  }
                  if (_controller.view == CalendarView.day) {
                    _headerText = DateFormat('MMMMEEEEd')
                        .format(viewChangedDetails.visibleDates[
                            viewChangedDetails.visibleDates.length ~/ 2])
                        .toString();
                  }
                  SchedulerBinding.instance.addPostFrameCallback((duration) {
                    setState(() {});
                  });
                }),
          )
        ],
      ),
    );
  }

  Row calendarHeader(MediaQueryData mediaQuery, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: mediaQuery.size.width * 0.38,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 20),
            child: Text(
              _headerText!,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 10),
          child: SizedBox(
            //width: mediaQuery.size.width * 0.03,
            child: PopupMenuButton(
              tooltip: 'Mode',
              icon: Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey[800],
              ),
              iconSize: 20,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<_calView>>[
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
                      _controller.view = CalendarView.day;
                    } else if (value == _calView.week) {
                      _controller.view = CalendarView.week;
                    } else if (value == _calView.month) {
                      _controller.view = CalendarView.month;
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
    );
  }

  void _calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      _cellDateText = DateFormat('MMMM dd').format(details.date!).toString();
      _startTimeText = DateFormat('jm').format(details.date!).toString();
      _endTimeText = DateFormat('jm')
          .format(details.date!.add(const Duration(minutes: 30)))
          .toString();
    }
    if (details.targetElement == CalendarElement.appointment) {
      final Appointment appointmentDetails = details.appointments![0];
      _subjectText = appointmentDetails.subject;
      _dateText =
          DateFormat('MMMM dd').format(appointmentDetails.startTime).toString();
      _startTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
      _endTimeText =
          DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
      _timeDetails = '$_startTimeText - $_endTimeText';
      // if (appointmentDetails._isAllDay) {
      //   _timeDetails = 'All day';
      // }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: AppointmentS(
                eventOrganizer: 'Maria Donosova',
                userProfiles: [],
                userCalendars: [],
                eventTitle: '',
                dateText: _cellDateText,
                to: _startTimeText,
                from: _endTimeText,
                catTitle: '',
                catColor: '',
                participants: '',
                eventBody: '',
                eventConferenceDetails: '',
                isAllDay: true,
                recurrenceId: '',
                recurrenceRule: '',
              ),
            );
          });
    } else
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: AppointmentS(
                eventOrganizer: 'Maria Donosova',
                userProfiles: [],
                userCalendars: [],
                eventTitle: '',
                dateText: _cellDateText,
                to: _startTimeText,
                from: _endTimeText,
                catTitle: '',
                catColor: '',
                participants: '',
                eventBody: '',
                eventConferenceDetails: '',
                isAllDay: true,
                recurrenceId: '',
                recurrenceRule: '',
              ),
            );
          });
  }
}
