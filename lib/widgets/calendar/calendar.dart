import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/models/event.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';

import 'appointment_builder.dart';
import '/widgets/calendar/week_days.dart';
// import '../shared/categories.dart';
import 'event_of_day.dart';
import 'month_cell_builder.dart';
import 'event_details.dart';

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
      _cellDateText;
  double? width, cellWidth;

  @override
  void initState() {
    _headerText = 'header';

    _subjectText = '';
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
                dataSource: _EventDataSource(getEvents()),
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
      //final Appointment appointmentDetails = details.appointments![0];
      final CustomAppointment customAppointment = details.appointments![0];

      // _subjectText = appointmentDetails.subject;
      // _dateText =
      //     DateFormat('MMMM dd').format(appointmentDetails.startTime).toString();
      _dateText =
          DateFormat('MMMM dd').format(customAppointment.startTime).toString();
      // _startTimeText =
      //     DateFormat('hh:mm a').format(appointmentDetails.startTime).toString();
      _startTimeText =
          DateFormat('hh:mm a').format(customAppointment.startTime).toString();
      // _endTimeText =
      //     DateFormat('hh:mm a').format(appointmentDetails.endTime).toString();
      _endTimeText =
          DateFormat('hh:mm a').format(customAppointment.endTime).toString();

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: EventDetails(
                eventOrganizer: '',
                userProfiles: [],
                userCalendars: [],
                //eventTitle: _subjectText,
                eventTitle: customAppointment.subject,
                dateText: _dateText,
                //from: _startTimeText,
                from: _startTimeText,
                //to: _endTimeText,
                to: _endTimeText,
                catTitle: customAppointment.catTitle,
                catColor: catColor(customAppointment.catTitle),
                participants: '',
                eventBody: customAppointment.notes,
                eventLocation: '',
                allDay: customAppointment.isAllDay,
                recurrenceId: '',
                recurrenceRule: customAppointment.recurrenceRule,
                recurrenceExceptions: [],
              ),
            );
          });
    } else
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: EventDetails(
                eventOrganizer: '',
                userProfiles: [],
                userCalendars: [],
                eventTitle: '',
                dateText: _cellDateText,
                from: _startTimeText,
                to: _endTimeText,
                catTitle: '',
                catColor: Colors.grey,
                participants: '',
                eventBody: '',
                eventLocation: '',
                allDay: false,
                recurrenceId: '',
                recurrenceRule: '',
                recurrenceExceptions: [],
              ),
            );
          });
  }
}

//dummy events
List<Event> events = [
  Event(
    eventOrganizer: 'Maria Donosova',
    eventTitle: 'Meeting with Team',
    from: DateTime(2024, 08, 25, 0, 10, 0),
    to: DateTime(2024, 08, 27, 23, 0, 0),
    isAllDay: false,
    eventBody: 'Discuss project updates',
    catTitle: 'Work',
    catColor: Colors.green,
  ),
  Event(
    eventOrganizer: 'Maria Donosova',
    eventTitle: 'Get Together',
    from: DateTime.now().add(Duration(hours: 2)),
    to: DateTime.now().add(Duration(hours: 4)),
    isAllDay: false,
    eventBody: 'Have a lot of fun',
    catTitle: 'Friends',
    catColor: Colors.yellow,
  )
];

//map syncfusion appointment properties to event properties
List<CustomAppointment> getEvents() {
  return events.map((event) {
    return CustomAppointment(
      // id: '123',
      subject: event.eventTitle,
      startTime: event.from,
      endTime: event.to,
      isAllDay: event.isAllDay,
      recurrenceId: '',
      recurrenceRule: '',
      catTitle: event.catTitle,
      catColor: catColor(event.catTitle),
      eventOrganizer: '',
      // participants: '',
      notes: event.eventBody,
      // eventConferenceDetails: '',
      // exceptionDates: ,
      // dateChanged: ,
      // dateCreated:
    );
  }).toList();
}

//data source connector
class _EventDataSource extends CalendarDataSource<CustomAppointment> {
  _EventDataSource(List<CustomAppointment> source) {
    appointments = source;
  }
  // @override
  // String? getId(int index) {
  //   return appointments![index].id;
  // }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  Object? getRecurrenceId(int index) {
    return appointments![index].recurrenceId as Object?;
  }

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) {
    return appointments![index].recurrenceExceptionDates as List<DateTime>?;
  }

  @override
  String? getRecurrenceRule(int index) {
    return appointments![index].recurrenceRule;
  }

  @override
  Color getColor(int index) {
    return appointments![index].catColor as Color;
  }

  @override
  CustomAppointment convertAppointmentToObject(
      CustomAppointment events, Appointment appointment) {
    return CustomAppointment(
            //id: appointment.id,
            subject: appointment.subject,
            startTime: appointment.startTime,
            endTime: appointment.endTime,
            catColor: appointment.color,
            isAllDay: appointment.isAllDay)
//          recurrenceRule: appointment.recurrenceRule,
//          recurrenceId: appointment.recurrenceId,
//          exceptionDates: appointment.recurrenceExceptionDates);
//   }
        ;
  }
}

class CustomAppointment {
  CustomAppointment({
    this.id = '',
    this.creator = '',
    // List<UserProfile> userProfiles = '',
    // List<UserCalendar> userCalendars = '',
    required this.startTime,
    required this.endTime,
    this.eventOrganizer = '',
    this.subject = '',
    this.isAllDay = false,
    this.startTimeZone,
    this.endTimeZone,
    this.recurrenceRule,
    this.recurrenceExceptionDates,
    this.recurrenceId,
    this.notes,
    this.location,
    this.resourceIds,
    this.catTitle = '',
    required this.catColor,
    this.participants = '',
  });
  String id;
  String? creator;
  // List<UserProfile> userProfiles;
  // List<UserCalendar> userCalendars;
  DateTime startTime;
  DateTime endTime;

  String? eventOrganizer;
  String subject;
  bool isAllDay;
  String? startTimeZone;
  String? endTimeZone;
  String? recurrenceRule;
  List<DateTime>? recurrenceExceptionDates;
  Object? recurrenceId;
  String? notes;
  String? location;
  List<Object>? resourceIds;
  String catTitle;
  Color catColor;
  String? participants;
}

// class CustomAppointment extends Appointment {
//   final String creator;
//   final String eventOrganizer;
//   // List<UserProfile> userProfiles;
//   // List<UserCalendar> userCalendars;
//   // bool reminder;
//   // bool holiday;
//   final String catTitle;
//   final Color catColor;
//   final String participants;

//   // DateTime dateCreated;
//   // DateTime dateChanged;

//   CustomAppointment({
//     this.creator = '',
//     // List<UserProfile> userProfiles = '',
//     // List<UserCalendar> userCalendars = '',
//     required DateTime startTime,
//     required DateTime endTime,
//     this.eventOrganizer = '',
//     String? subject,
//     Color? color,
//     required bool isAllDay,
//     String? startTimeZone,
//     String? endTimeZone,
//     String? recurrenceRule,
//     List<DateTime>? recurrenceExceptionDates,
//     Object? recurrenceId,
//     String? notes,
//     String? location,
//     List<Object>? resourceIds,
//     this.catTitle = '',
//     required this.catColor,
//     this.participants = '',
//   }) : super(
//           startTime: startTime,
//           endTime: endTime,
//           subject: subject ?? '',
//           color: catColor,
//           isAllDay: isAllDay,
//           startTimeZone: startTimeZone,
//           endTimeZone: endTimeZone,
//           recurrenceRule: recurrenceRule,
//           recurrenceExceptionDates: recurrenceExceptionDates,
//           recurrenceId: recurrenceId,
//           notes: notes,
//           location: location,
//           resourceIds: resourceIds,
//         );
// }
