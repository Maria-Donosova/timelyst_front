import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../views/weekDays.dart';
import '../views/appointmentCellBuilder.dart';
import '../views/monthlyAppointmentCellBuilder.dart';
import '../views/eventDetails.dart';
import '../../../models/customApp.dart';
import '../../../providers/eventProvider.dart';
import '../../../utils/logger.dart';
import '../../responsive/responsive_widgets.dart';

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
    
    // Note: Initial event loading will be handled by the onViewChanged callback
    // when the calendar first loads, so we don't need duplicate loading here
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = MediaQuery.of(context).size.width;
    final cellWidth = width / 14;
    final isMonth = _controller.view == CalendarView.month;
    final isWeek = _controller.view == CalendarView.week;

    final eventProvider = Provider.of<EventProvider>(context);

    final List<CustomAppointment> appointments = eventProvider.events;

    // Essential logging only
    if (appointments.length > 0) {
      print('📅 [Calendar] Building calendar with ${appointments.length} events');
    }
    
    AppLogger.performance('Building calendar with ${appointments.length} events', 'Calendar');

    return Card(
      child: Column(
        children: [
          Column(children: [
            calendarHeader(mediaQuery, context),
            isMonth
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getValue(context, mobile: 8.0, tablet: 10.0, desktop: 12.0)
                    ),
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
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getValue(context, mobile: 8.0, tablet: 10.0, desktop: 12.0)
                        ),
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
            child: Stack(
              children: [
                SfCalendar(
                    view: CalendarView.day,
                    allowedViews: const [
                      CalendarView.day,
                      CalendarView.week,
                      CalendarView.month
                    ],
                    timeSlotViewSettings: TimeSlotViewSettings(
                      timeIntervalHeight: 50,
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
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                      showTrailingAndLeadingDates: false,
                    ),
                    appointmentBuilder: appointmentBuilder,
                    allowAppointmentResize: true,
                    allowDragAndDrop: true,
                    dragAndDropSettings:
                        DragAndDropSettings(showTimeIndicator: true),
                    dataSource: _EventDataSource(appointments),
                    onTap: _calendarTapped,
                    onDragEnd: _handleDragEnd,
                    onViewChanged: (ViewChangedDetails viewChangedDetails) {
                      final eventProvider = Provider.of<EventProvider>(context, listen: false);
                      
                      // Invalidate cache when view changes to ensure fresh data
                      eventProvider.invalidateCache();
                      print('📅 [Calendar] View changed - cache invalidated for fresh event data');
                      
                      if (_controller.view == CalendarView.month) {
                        _headerText = DateFormat('yMMMM')
                            .format(viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2])
                            .toString();
                        
                        // Fetch events for the visible month
                        final visibleMonth = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
                        eventProvider.fetchMonthViewEvents(month: visibleMonth);
                      }
                      if (_controller.view == CalendarView.week) {
                        final visibleDatesLength =
                            viewChangedDetails.visibleDates.length;
                        _weekStart = DateFormat('d')
                            .format(viewChangedDetails.visibleDates[0])
                            .toString();
                        _weekEnd = DateFormat('d')
                            .format(viewChangedDetails.visibleDates[
                                visibleDatesLength > 6
                                    ? 6
                                    : visibleDatesLength - 1])
                            .toString();
                        _month = DateFormat('MMMM')
                            .format(viewChangedDetails.visibleDates[0])
                            .toString();
                        _headerText =
                            _month! + ' ' + _weekStart! + ' - ' + _weekEnd!;
                        
                        // Fetch events for the visible week
                        final weekStart = viewChangedDetails.visibleDates[0];
                        eventProvider.fetchWeekViewEvents(weekStart: weekStart);
                      }
                      if (_controller.view == CalendarView.day) {
                        _headerText = DateFormat('MMMMEEEEd')
                            .format(viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2])
                            .toString();
                        
                        // Fetch events for the visible day
                        final visibleDay = viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/ 2];
                        eventProvider.fetchDayViewEvents(date: visibleDay);
                      }
                      SchedulerBinding.instance.addPostFrameCallback((duration) {
                        setState(() {});
                      });
                    }),
                if (eventProvider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
              ],
            ),
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
            padding: EdgeInsets.only(
              left: ResponsiveHelper.getValue(context, mobile: 10.0, tablet: 12.0, desktop: 15.0),
              right: ResponsiveHelper.getValue(context, mobile: 20.0, tablet: 24.0, desktop: 30.0),
            ),
            child: Text(
              _headerText!,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 10),
          child: SizedBox(
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
                final eventProvider = Provider.of<EventProvider>(context, listen: false);
                
                setState(
                  () {
                    // Invalidate cache when user manually switches views
                    eventProvider.invalidateCache();
                    print('📅 [Calendar] Manual view switch - cache invalidated for fresh event data');
                    
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
          ),
        ),
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
      if (details.appointments != null && details.appointments!.isNotEmpty) {
        final CustomAppointment _customAppointment = details.appointments![0];

        _dateText = DateFormat('MMM dd')
            .format(_customAppointment.startTime)
            .toString();

        _startTimeText = DateFormat('hh:mm a')
            .format(_customAppointment.startTime)
            .toString();

        _endTimeText =
            DateFormat('hh:mm a').format(_customAppointment.endTime).toString();

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: EventDetails(
                  id: _customAppointment.id,
                  subject: _customAppointment.title,
                  dateText: _dateText,
                  start: _startTimeText,
                  end: _endTimeText,
                  catTitle: _customAppointment.catTitle,
                  catColor: _customAppointment.catColor,
                  participants: _customAppointment.participants,
                  body: _customAppointment.description,
                  location: _customAppointment.location,
                  isAllDay: _customAppointment.isAllDay,
                  recurrenceRule: _customAppointment.recurrenceRule,
                ),
              );
            });
      }
    } else
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: EventDetails(
                id: '',
                subject: '',
                dateText: _cellDateText,
                start: _startTimeText,
                end: _endTimeText,
                catTitle: '',
                catColor: Colors.grey,
                participants: '',
                body: '',
                isAllDay: false,
                recurrenceRule: '',
                location: '',
              ),
            );
          });
  }

  /// Handles drag-and-drop operations, especially for recurring events
  void _handleDragEnd(AppointmentDragEndDetails details) {
    if (details.appointment != null) {
      final oldAppointment = details.appointment as CustomAppointment;
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      AppLogger.debug('Handling drag-and-drop for appointment: ${oldAppointment.title}', 'Calendar');
      AppLogger.debug('Is recurring: ${oldAppointment.recurrenceRule != null}', 'Calendar');
      
      // Calculate the duration of the event
      final duration = oldAppointment.endTime.difference(oldAppointment.startTime);
      
      if (oldAppointment.recurrenceRule != null) {
        // Handle recurring event drag-and-drop
        AppLogger.debug('Handling recurring event drag-and-drop', 'Calendar');
        
        // Add the old appointment start date to recurrenceExceptionDates
        final updatedExceptionDates = <DateTime>[
          if (oldAppointment.recurrenceExceptionDates != null)
            ...oldAppointment.recurrenceExceptionDates!,
          oldAppointment.startTime
        ];

        // Create a new appointment at the new drop location with updated exceptions
        final newAppointment = CustomAppointment(
          id: oldAppointment.id,
          title: oldAppointment.title,
          description: oldAppointment.description,
          startTime: details.droppingTime!,
          endTime: details.droppingTime!.add(duration),
          catTitle: oldAppointment.catTitle,
          catColor: oldAppointment.catColor,
          participants: oldAppointment.participants,
          location: oldAppointment.location,
          organizer: oldAppointment.organizer,
          isAllDay: oldAppointment.isAllDay,
          recurrenceRule: oldAppointment.recurrenceRule,
          recurrenceExceptionDates: updatedExceptionDates,
          userCalendars: oldAppointment.userCalendars,
          timeEventInstance: oldAppointment.timeEventInstance,
        );

        // Update the event in the provider
        eventProvider.updateEvent(oldAppointment, newAppointment);
        AppLogger.debug('Updated recurring event with exception date', 'Calendar');
        
      } else {
        // Handle non-recurring event drag-and-drop
        AppLogger.debug('Handling non-recurring event drag-and-drop', 'Calendar');
        
        final updatedAppointment = CustomAppointment(
          id: oldAppointment.id,
          title: oldAppointment.title,
          description: oldAppointment.description,
          startTime: details.droppingTime!,
          endTime: details.droppingTime!.add(duration),
          catTitle: oldAppointment.catTitle,
          catColor: oldAppointment.catColor,
          participants: oldAppointment.participants,
          location: oldAppointment.location,
          organizer: oldAppointment.organizer,
          isAllDay: oldAppointment.isAllDay,
          recurrenceRule: oldAppointment.recurrenceRule,
          recurrenceExceptionDates: oldAppointment.recurrenceExceptionDates,
          userCalendars: oldAppointment.userCalendars,
          timeEventInstance: oldAppointment.timeEventInstance,
        );

        // Update the event in the provider
        eventProvider.updateEvent(oldAppointment, updatedAppointment);
        AppLogger.debug('Updated non-recurring event', 'Calendar');
      }
      
      // Refresh the calendar view
      setState(() {});
    }
  }

  void addEventAndRefresh(CustomAppointment event) {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        eventProvider.addSingleEvent(event);
        setState(() {});
      });
    }
  }
}

class _EventDataSource extends CalendarDataSource<CustomAppointment> {
  _EventDataSource(List<CustomAppointment> source) {
    AppLogger.performance('Creating data source with ${source.length} appointments', '_EventDataSource');
    
    // Debug recurring events specifically
    final recurringAppointments = source.where((a) => a.recurrenceRule != null && a.recurrenceRule!.isNotEmpty).toList();
    AppLogger.debug('Found ${recurringAppointments.length} recurring appointments:', '_EventDataSource');
    for (final appointment in recurringAppointments) {
      AppLogger.verbose('  - "${appointment.title}": ${appointment.recurrenceRule}', '_EventDataSource');
      AppLogger.verbose('    Start: ${appointment.startTime}, End: ${appointment.endTime}', '_EventDataSource');
      if (appointment.recurrenceExceptionDates != null) {
        AppLogger.verbose('    Exception dates: ${appointment.recurrenceExceptionDates}', '_EventDataSource');
      }
    }
    
    appointments = source;
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
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return appointments![index].catColor;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    final rule = appointments![index].recurrenceRule;
    if (rule != null && rule.isNotEmpty) {
      AppLogger.verbose('getRecurrenceRule for "${appointments![index].title}": "$rule"', '_EventDataSource');
      
      try {
        // Fix malformed RRULE dates from backend (temporary until backend is updated)
        final fixedRule = _fixMalformedRRule(rule);
        if (fixedRule != rule) {
          AppLogger.debug('Fixed malformed RRULE: "$rule" -> "$fixedRule"', '_EventDataSource');
        }
        
        // Validate the RRULE format before returning
        if (_isValidRRule(fixedRule)) {
          return fixedRule;
        } else {
          AppLogger.debug('Invalid RRULE format, skipping: "$fixedRule"', '_EventDataSource');
          return null;
        }
      } catch (e) {
        AppLogger.e('Error processing RRULE "$rule": $e', '_EventDataSource');
        return null;
      }
    }
    return rule;
  }

  /// Validates RRULE format for Syncfusion
  bool _isValidRRule(String rrule) {
    // Basic validation - must start with RRULE: and contain FREQ=
    if (!rrule.startsWith('RRULE:') || !rrule.contains('FREQ=')) {
      return false;
    }
    
    // Check if UNTIL date format is valid (8 digits for date part)
    final untilMatch = RegExp(r'UNTIL=(\d{8})T').firstMatch(rrule);
    if (rrule.contains('UNTIL=') && untilMatch == null) {
      return false;
    }
    
    return true;
  }

  /// Fixes malformed RRULE dates from Google Calendar API
  /// Converts UNTIL=202709T000000Z to UNTIL=20270901T000000Z
  String _fixMalformedRRule(String rrule) {
    // Handle malformed UNTIL dates (YYYYMM instead of YYYYMMDD)
    final untilRegex = RegExp(r'UNTIL=(\d{6})T(\d{6}Z)');
    
    return rrule.replaceAllMapped(untilRegex, (match) {
      final datepart = match.group(1)!;
      final timepart = match.group(2)!;
      
      if (datepart.length == 6) {
        // Add day "01" to make it a valid date (YYYYMM01)
        final fixedDate = datepart + '01';
        AppLogger.debug('Fixed malformed date: $datepart -> $fixedDate', '_EventDataSource');
        return 'UNTIL=${fixedDate}T$timepart';
      }
      
      return match.group(0)!;
    });
  }

  @override
  List<DateTime>? getRecurrenceExceptionDates(int index) {
    return appointments![index].recurrenceExceptionDates;
  }

  @override
  String getNotes(int index) {
    return appointments![index].description;
  }

  @override
  String getLocation(int index) {
    return appointments![index].location;
  }

  @override
  CustomAppointment convertAppointmentToObject(
      CustomAppointment _customAppointment, Appointment appointment) {
    return CustomAppointment(
        id: appointment.id.toString(),
        userCalendars: _customAppointment.userCalendars,
        title: appointment.subject,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        catTitle: _customAppointment.catTitle,
        catColor: _customAppointment.catColor,
        isAllDay: appointment.isAllDay,
        description: _customAppointment.description,
        location: _customAppointment.location,
        participants: _customAppointment.participants,
        recurrenceRule: appointment.recurrenceRule,
        recurrenceExceptionDates: appointment.recurrenceExceptionDates,
        timeEventInstance: _customAppointment.timeEventInstance);
  }
}