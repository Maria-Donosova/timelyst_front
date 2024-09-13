import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:timelyst_flutter/widgets/calendar/models/custom_appointment.dart';

import 'screens/week_days.dart';
import 'screens/appointment_cell_builder.dart';
import 'screens/monthly_appointment_cell_builder.dart';
import 'screens/appointment_details.dart';

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
      _startTimeText,
      _endTimeText,
      _dateText,
      _cellDateText;
  double? width, cellWidth;

  @override
  void initState() {
    _headerText = 'header';

    _startTimeText = '';
    _endTimeText = '';
    _dateText = '';

    _cellDateText = '';

    width = 0.0;
    cellWidth = 0.0;

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
                            viewHeaderText6: 'Sun',
                            viewHeaderText: 'Mon',
                            viewHeaderText1: 'Tue',
                            viewHeaderText2: 'Wed',
                            viewHeaderText3: 'Thur',
                            viewHeaderText4: 'Fri',
                            viewHeaderText5: 'Sun'),
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
                timeSlotViewSettings: TimeSlotViewSettings(
                  timeIntervalHeight: 50,
                  //allDayPanelColor: Theme.of(context).colorScheme.shadow,
                ),
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
                dragAndDropSettings:
                    DragAndDropSettings(showTimeIndicator: true),
                dataSource: _EventDataSource(_appointments),
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
      final CustomAppointment _customAppointment = details.appointments![0];

      _dateText =
          DateFormat('MMM dd').format(_customAppointment.startTime).toString();

      _startTimeText =
          DateFormat('hh:mm a').format(_customAppointment.startTime).toString();

      _endTimeText =
          DateFormat('hh:mm a').format(_customAppointment.endTime).toString();

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: EventDetails(
                id: _customAppointment.id,
                // creator: '',
                // userProfiles: [],
                // userCalendars: [],
                // eventOrganizer: '',
                subject: _customAppointment.subject,
                dateText: _dateText,
                startTime: _startTimeText,
                endTime: _endTimeText,
                catTitle: _customAppointment.catTitle,
                catColor: _customAppointment.catColor,
                participants: _customAppointment.participants,
                body: _customAppointment.description,
                location: _customAppointment.location,
                isAllDay: _customAppointment.isAllDay,
                // recurrenceId: '',
                // recurrenceRule: _customAppointment.recurrenceRule,
                // recurrenceExceptionDates: [],
              ),
            );
          });
    } else
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: EventDetails(
                id: '',
                // eventOrganizer: '',
                // userProfiles: [],
                // userCalendars: [],
                subject: '',
                dateText: _cellDateText,
                startTime: _startTimeText,
                endTime: _endTimeText,
                catTitle: '',
                catColor: Colors.grey,
                participants: '',
                body: '',
                isAllDay: false,
                // recurrenceId: '',
                // recurrenceRule: '',
                location: '',
                // recurrenceExceptionDates: [],
              ),
            );
          });
  }
}

//dummy events
List<CustomAppointment> _appointments = [
  CustomAppointment(
    subject: 'Meeting with Team',
    startTime: DateTime(2024, 09, 13, 0, 00, 0),
    endTime: DateTime(2024, 09, 16, 23, 59, 0),
    isAllDay: true,
    // recurrenceRule: 'FREQ=MONTHLY;BYMONTHDAY=-1;INTERVAL=1;COUNT=10',
    catTitle: 'Work',
    catColor: Color.fromRGBO(8, 100, 237, 1),
    participants: 'tim@gmail.com, tom@gmail.com, cook@test.com',
    description: 'Discuss project updates',
    location: 'Conference Room 1',
  ),
  CustomAppointment(
    subject: 'Get Together',
    startTime: DateTime.now().add(Duration(hours: 1)),
    endTime: DateTime.now().add(Duration(hours: 3)),
    isAllDay: false,
    // recurrenceRule: 'FREQ=DAILY;INTERVAL=2;COUNT=10',
    catTitle: 'Friends',
    catColor: Color.fromRGBO(255, 239, 91, 1),
    participants: 'john@test.com, jane@test.com, jim@test.com',
    description: 'Have a lot of fun',
    location: 'Cafe',
  )
];

// //map syncfusion appointment properties to custom appointment properties
// List<CustomAppointment> getEvents() {
//   return _appointments.map((appointment) {
//     return CustomAppointment(
//       id: appointment.id,
//       subject: appointment.subject,
//       startTime: appointment.startTime,
//       endTime: appointment.endTime,
//       isAllDay: appointment.isAllDay,
//       // recurrenceId: appointment.recurrenceId,
//       // recurrenceRule: appointment.recurrenceRule,
//       //catTitle: appointment.catTitle,
//       catColor: appointment.catColor,
//       // eventOrganizer: '',
//       participants: appointment.participants,
//       body: appointment.body,
//       // eventConferenceDetails: '',
//       location: appointment.location,
//       // exceptionDates: ,
//       // dateChanged: ,
//       // dateCreated:
//     );
//   }).toList();
// }

//datasource connector: override syncfusion appointment properties with custom appointment properties
class _EventDataSource extends CalendarDataSource<CustomAppointment> {
  _EventDataSource(List<CustomAppointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _appointments[index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return _appointments[index].endTime;
  }

  @override
  String getStartTimeZone(int index) {
    return _appointments[index].startTimeZone;
  }

  @override
  String getEndTimeZone(int index) {
    return _appointments[index].endTimeZone;
  }

  @override
  String getSubject(int index) {
    return _appointments[index].subject;
  }

  @override
  Color getColor(int index) {
    return _appointments[index].catColor;
  }

  @override
  bool isAllDay(int index) {
    return _appointments[index].isAllDay;
  }

  // @override
  // String? getRecurrenceRule(int index) {
  //   return _appointments[index].recurrenceRule;
  // }

  @override
  String getNotes(int index) {
    return _appointments[index].description;
  }

  @override
  String getLocation(int index) {
    return _appointments[index].location;
  }

  // @override
  // Object? getRecurrenceId(int index) {
  //   return appointments[index].recurrenceId as Object?;
  // }

  // @override
  // List<DateTime>? getRecurrenceExceptionDates(int index) {
  //   return appointments[index].recurrenceExceptionDates as List<DateTime>?;
  // }

  @override
  CustomAppointment convertAppointmentToObject(
      CustomAppointment _customAppointment, Appointment appointment) {
    return CustomAppointment(
      id: appointment.id.toString(),
      subject: appointment.subject,
      startTime: appointment.startTime,
      endTime: appointment.endTime,
      catTitle: _customAppointment.catTitle,
      // catColor: appointment.color,
      isAllDay: appointment.isAllDay,
      description: _customAppointment.description,
      location: _customAppointment.location,
      participants: _customAppointment.participants,
      // recurrenceRule: appointment.recurrenceRule,
//    recurrenceId: appointment.recurrenceId,
//    recurrenceExceptionDates: appointment.recurrenceExceptionDates);
//   }
    );
  }
}
