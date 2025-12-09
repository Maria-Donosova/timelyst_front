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
import '../../../providers/calendarProvider.dart';
import '../../../providers/authProvider.dart';
import '../../../utils/logger.dart';
import '../../responsive/responsive_widgets.dart';
import '../../../services/event_handler_service.dart';
import '../../../data_sources/timelyst_calendar_data_source.dart';

enum _calView { day, week, month }

class CalendarW extends StatefulWidget {
  const CalendarW({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarWState();
}

class _CalendarWState extends State<CalendarW> {
  final CalendarController _controller = CalendarController();
  List<DateTime> _visibleDates = [];
  TimelystCalendarDataSource? _dataSource;

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

  /// Loads events for the current visible date range using the new calendar view API
  Future<void> _loadEvents() async {
    if (_visibleDates.isEmpty) return;

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Use new calendar view API
    await eventProvider.fetchCalendarView(
      startDate: _visibleDates.first,
      endDate: _visibleDates.last.add(const Duration(days: 1)),
    );

    // Get TimeEvent objects from provider
    final timeEvents = eventProvider.timeEvents;
    
    // Separate masters and exceptions
    final masters = timeEvents.where((e) => e.isMasterEvent || !e.isRecurring).toList();
    final exceptions = timeEvents.where((e) => e.isException).toList();
    
    // Build occurrence counts map
    final occurrenceCounts = <String, int>{};
    for (final master in masters) {
      if (master.isMasterEvent) {
        occurrenceCounts[master.id] = eventProvider.getOccurrenceCount(master.id);
      }
    }
    
    // Create data source
    setState(() {
      _dataSource = TimelystCalendarDataSource(
        masterEvents: masters,
        exceptionEvents: exceptions,
        occurrenceCounts: occurrenceCounts,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = MediaQuery.of(context).size.width;
    final cellWidth = width / 14;
    final isMonth = _controller.view == CalendarView.month;
    final isWeek = _controller.view == CalendarView.week;

    final eventProvider = Provider.of<EventProvider>(context);
    // Listen to CalendarProvider to trigger rebuilds when calendars are loaded/updated
    Provider.of<CalendarProvider>(context);

    final List<CustomAppointment> appointments = eventProvider.events;

    // Essential logging only
    if (appointments.length > 0) {
      print(
          '📅 [Calendar] Building calendar with ${appointments.length} events');
    }

    AppLogger.performance(
        'Building calendar with ${appointments.length} events', 'Calendar');

    return Card(
      child: Column(
        children: [
          Column(children: [
            calendarHeader(mediaQuery, context),
            isMonth
                ? Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.getValue(context,
                            mobile: 8.0, tablet: 10.0, desktop: 12.0)),
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
                            vertical: ResponsiveHelper.getValue(context,
                                mobile: 8.0, tablet: 10.0, desktop: 12.0)),
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
                      textStyle:
                          TextStyle(fontSize: 8, color: Colors.grey[600]),
                    ),
                    todayHighlightColor: Color.fromRGBO(171, 178, 183, 1),
                    todayTextStyle: TextStyle(color: Colors.grey[800]),
                    showNavigationArrow: true,
                    showCurrentTimeIndicator: true,
                    monthCellBuilder: monthCellBuilder,
                    monthViewSettings: MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      showTrailingAndLeadingDates: false,
                    ),
                    appointmentBuilder: appointmentBuilder,
                    allowAppointmentResize: true,
                    allowDragAndDrop: true,
                    dragAndDropSettings:
                        DragAndDropSettings(showTimeIndicator: true),
                    dataSource: (_dataSource ?? _EventDataSource(appointments)) as CalendarDataSource<Object?>?,
                    onTap: _calendarTapped,
                    onDragEnd: _handleDragEnd,
                    onAppointmentResizeEnd: _handleResizeEnd,
                    onViewChanged: (ViewChangedDetails viewChangedDetails) {
                      // Track visible dates for _loadEvents
                      _visibleDates = viewChangedDetails.visibleDates;

                      final eventProvider =
                          Provider.of<EventProvider>(context, listen: false);

                      // Invalidate cache when view changes to ensure fresh data
                      eventProvider.invalidateCache();
                      print(
                          '📅 [Calendar] View changed - cache invalidated for fresh event data');

                      if (_controller.view == CalendarView.month) {
                        _headerText = DateFormat('yMMMM')
                            .format(viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2])
                            .toString();
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
                      }
                      if (_controller.view == CalendarView.day) {
                        _headerText = DateFormat('MMMMEEEEd')
                            .format(viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2])
                            .toString();
                      }

                      // Load events using the new calendar view API
                      _loadEvents();

                      SchedulerBinding.instance
                          .addPostFrameCallback((duration) {
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
              left: ResponsiveHelper.getValue(context,
                  mobile: 10.0, tablet: 12.0, desktop: 15.0),
              right: ResponsiveHelper.getValue(context,
                  mobile: 20.0, tablet: 24.0, desktop: 30.0),
            ),
            child: Text(
              _headerText!,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, left: 10),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Today',
                icon: Icon(
                  Icons.today,
                  color: Colors.grey[800],
                ),
                iconSize: 20,
                onPressed: () {
                  final eventProvider =
                      Provider.of<EventProvider>(context, listen: false);

                  setState(() {
                    // Invalidate cache when user manually switches views
                    eventProvider.invalidateCache();
                    print(
                        '📅 [Calendar] Manual switch to Today - cache invalidated for fresh event data');

                    _controller.view = CalendarView.day;
                    _controller.displayDate = DateTime.now();
                  });
                },
              ),
              SizedBox(
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
                final eventProvider =
                    Provider.of<EventProvider>(context, listen: false);

                setState(
                  () {
                    // Invalidate cache when user manually switches views
                    eventProvider.invalidateCache();
                    print(
                        '📅 [Calendar] Manual view switch - cache invalidated for fresh event data');

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
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _calendarTapped(CalendarTapDetails details) async {
    if (details.targetElement == CalendarElement.calendarCell) {
      _cellDateText = DateFormat('MMMM d', 'en_US').format(details.date!).toString();
      _startTimeText = DateFormat('jm').format(details.date!).toString();
      _endTimeText = DateFormat('jm')
          .format(details.date!.add(const Duration(minutes: 60)))
          .toString();
    }
    if (details.targetElement == CalendarElement.appointment) {
      if (details.appointments != null && details.appointments!.isNotEmpty) {
        final dynamic rawAppointment = details.appointments![0];
        CustomAppointment? _customAppointment;
        
        if (rawAppointment is CustomAppointment) {
          _customAppointment = rawAppointment;
        } else if (rawAppointment is Appointment) {
          // Handle Syncfusion generated occurrence
          final eventProvider = Provider.of<EventProvider>(context, listen: false);
          // Try to find by ID if available (from overridden getId)
          if (rawAppointment.id != null) {
            final master = eventProvider.events.firstWhere(
              (e) => e.id == rawAppointment.id,
              orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
            );
            if (master.id != 'temp') {
              _customAppointment = master.copyWith(
                startTime: rawAppointment.startTime,
                endTime: rawAppointment.endTime,
                isAllDay: rawAppointment.isAllDay,
                recurrenceId: rawAppointment.recurrenceId?.toString(), // Pass ID if available? Or leave as is?
                // Actually recurrenceId for an occurrence is usually pointing to master? 
                // But CustomAppointment structure uses recurrenceId strictly for exceptions?
                // For display in dialog, we want to show it as an instance of the master.
              );
            }
          }
        }

        if (_customAppointment != null) {
          _dateText = DateFormat('MMMM d', 'en_US')
              .format(_customAppointment.startTime)
              .toString();

          _startTimeText = DateFormat('hh:mm a')
              .format(_customAppointment.startTime)
              .toString();

          _endTimeText =
              DateFormat('hh:mm a').format(_customAppointment.endTime).toString();

          final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: EventDetails(
                    id: _customAppointment!.id,
                    subject: _customAppointment!.title,
                    dateText: _dateText,
                    start: _startTimeText,
                    end: _endTimeText,
                    catTitle: _customAppointment!.catTitle,
                    catColor: _customAppointment!.catColor,
                    participants: _customAppointment!.participants,
                    body: _customAppointment!.description,
                    location: _customAppointment!.location,
                    isAllDay: _customAppointment!.isAllDay,
                    recurrenceRule: _customAppointment!.recurrenceRule,
                    recurrenceId: _customAppointment!.recurrenceId,
                    originalStart: _customAppointment!.originalStart,
                    exDates: _customAppointment!.exDates,
                    calendarId: _customAppointment!.calendarId,
                  ),
                );
              });
          
          if (result == true) {
            setState(() {});
          }
        }
      }


    } else {
      final result = await showDialog(
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

      if (result == true) {
        setState(() {});
      }
    }
  }

  /// Converts a CustomAppointment to the backend API payload format
  Map<String, dynamic> _createEventPayload(CustomAppointment appointment) {
    final payload = <String, dynamic>{
      'eventTitle': appointment.title,
      'start': appointment.startTime.toUtc().toIso8601String(),
      'end': appointment.endTime.toUtc().toIso8601String(),
      'calendarIds': appointment.userCalendars,
      'isAllDay': appointment.isAllDay,
      'location': appointment.location,
      'description': appointment.description,
      'category': appointment.catTitle,
    };

    // Include recurrence rule if present
    if (appointment.recurrenceRule != null && appointment.recurrenceRule!.isNotEmpty) {
      payload['recurrenceRule'] = appointment.recurrenceRule;
    }

    // Include recurrence ID if present (for recurring event instances)
    if (appointment.recurrenceId != null) {
      payload['recurrenceId'] = appointment.recurrenceId;
    }

    return payload;
  }

  /// Handles drag-and-drop operations, especially for recurring events
  Future<void> _handleDragEnd(AppointmentDragEndDetails details) async {
    if (details.appointment == null) return;

    CustomAppointment? appointment;
    final dynamic rawAppointment = details.appointment!;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (rawAppointment is CustomAppointment) {
      appointment = rawAppointment;
    } else if (rawAppointment is Appointment) {
      // Resolve master from ID - Syncfusion drag details returns the occurrence
       if (rawAppointment.id != null) {
          final master = eventProvider.events.firstWhere(
            (e) => e.id == rawAppointment.id,
            orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
          );
          if (master.id != 'temp') {
            appointment = master.copyWith(
              startTime: rawAppointment.startTime, 
              endTime: rawAppointment.endTime,
            );
          }
       }
    }
    
    if (appointment == null) return;

    AppLogger.debug(
        'Handling drag-and-drop for appointment: ${appointment.title}',
        'Calendar');

    // Calculate the duration of the event
    final duration = appointment.endTime.difference(appointment.startTime);

    if (appointment.isRecurring) {
      // Handle recurring event with EventHandlerService
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authToken = await authProvider.authService.getAuthToken();

      if (authToken == null) {
        AppLogger.e('No auth token available for drag-and-drop', 'Calendar');
        return;
      }

      final handler = EventHandlerService(authToken: authToken);

      // Get master ID and occurrence count
      final masterId = appointment.recurrenceId ?? appointment.id;
      final occurrenceCount = eventProvider.getOccurrenceCount(masterId);

      try {
        await handler.handleDragDrop(
          context: context,
          appointment: appointment,
          newStartTime: details.droppingTime!,
          eventDuration: duration,
          totalOccurrences: occurrenceCount,
        );

        // Refresh calendar after successful update
        await _loadEvents();
      } catch (e) {
        AppLogger.e('Error handling recurring event drag-and-drop: $e', 'Calendar');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update event: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Handle non-recurring event - simple update
      final updatedAppointment = CustomAppointment(
        id: appointment.id,
        title: appointment.title,
        description: appointment.description,
        startTime: details.droppingTime!,
        endTime: details.droppingTime!.add(duration),
        catTitle: appointment.catTitle,
        catColor: appointment.catColor,
        participants: appointment.participants,
        location: appointment.location,
        organizer: appointment.organizer,
        isAllDay: appointment.isAllDay,
        recurrenceRule: appointment.recurrenceRule,
        recurrenceExceptionDates: appointment.recurrenceExceptionDates,
        userCalendars: appointment.userCalendars,
        timeEventInstance: appointment.timeEventInstance,
      );

      // Optimistic UI update
      eventProvider.updateEventLocal(appointment, updatedAppointment);
      setState(() {});

      // Persist to backend
      try {
        final eventPayload = _createEventPayload(updatedAppointment);
        final result = await eventProvider.updateEvent(
          appointment.id,
          eventPayload,
        );

        if (result == null) {
          throw Exception('Update returned null');
        }

        AppLogger.debug('Successfully updated non-recurring event', 'Calendar');
      } catch (e) {
        AppLogger.e('Error updating non-recurring event: $e', 'Calendar');
        
        // Revert on error
        eventProvider.updateEventLocal(updatedAppointment, appointment);
        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save event changes: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// Handles appointment resize operations
  Future<void> _handleResizeEnd(AppointmentResizeEndDetails details) async {
    if (details.appointment == null) return;

    CustomAppointment? appointment;
    final dynamic rawAppointment = details.appointment!;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (rawAppointment is CustomAppointment) {
      appointment = rawAppointment;
    } else if (rawAppointment is Appointment) {
      // Resolve master from ID
       if (rawAppointment.id != null) {
          final master = eventProvider.events.firstWhere(
            (e) => e.id == rawAppointment.id,
             orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
          );
          if (master.id != 'temp') {
            appointment = master; 
            // We use master base, but resize details gives us new start/end times via details.startTime/endTime
          }
       }
    }

    if (appointment == null) return;

    AppLogger.debug(
        'Handling resize for appointment: ${appointment.title}',
        'Calendar');

    if (appointment.isRecurring) {
      // Handle recurring event with EventHandlerService
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authToken = await authProvider.authService.getAuthToken();

      if (authToken == null) {
        AppLogger.e('No auth token available for resize', 'Calendar');
        return;
      }

      final handler = EventHandlerService(authToken: authToken);

      // Get master ID and occurrence count
      final masterId = appointment.recurrenceId ?? appointment.id;
      final occurrenceCount = eventProvider.getOccurrenceCount(masterId);

      // Build update payload with new times
      final updates = {
        'start': details.startTime!.toUtc().toIso8601String(),
        'end': details.endTime!.toUtc().toIso8601String(),
      };

      try {
        // Use handleEventEdit for resize operations on recurring events
        await handler.handleEventEdit(
          context: context,
          appointment: appointment,
          updates: updates,
          occurrenceDate: appointment.startTime,
          totalOccurrences: occurrenceCount,
        );

        // Refresh calendar after successful update
        await _loadEvents();
      } catch (e) {
        AppLogger.e('Error handling recurring event resize: $e', 'Calendar');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update event: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // Handle non-recurring event - simple update
      final updatedAppointment = CustomAppointment(
        id: appointment.id,
        title: appointment.title,
        description: appointment.description,
        startTime: details.startTime!,
        endTime: details.endTime!,
        catTitle: appointment.catTitle,
        catColor: appointment.catColor,
        participants: appointment.participants,
        location: appointment.location,
        organizer: appointment.organizer,
        isAllDay: appointment.isAllDay,
        recurrenceRule: appointment.recurrenceRule,
        recurrenceExceptionDates: appointment.recurrenceExceptionDates,
        recurrenceId: appointment.recurrenceId,
        userCalendars: appointment.userCalendars,
        timeEventInstance: appointment.timeEventInstance,
      );

      // Optimistic UI update
      eventProvider.updateEventLocal(appointment, updatedAppointment);
      setState(() {});

      // Persist to backend
      try {
        final eventPayload = _createEventPayload(updatedAppointment);
        final result = await eventProvider.updateEvent(
          appointment.id,
          eventPayload,
        );

        if (result == null) {
          throw Exception('Update returned null');
        }

        AppLogger.debug('Successfully updated non-recurring event', 'Calendar');
      } catch (e) {
        AppLogger.e('Error updating non-recurring event: $e', 'Calendar');
        
        // Revert on error
        eventProvider.updateEventLocal(updatedAppointment, appointment);
        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save event changes: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void addEventAndRefresh(CustomAppointment event) {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final eventProvider =
            Provider.of<EventProvider>(context, listen: false);
        eventProvider.addSingleEvent(event);
        setState(() {});
      });
    }
  }
}

class _EventDataSource extends CalendarDataSource<CustomAppointment> {
  _EventDataSource(List<CustomAppointment> source) {
    AppLogger.performance(
        'Creating data source with ${source.length} appointments',
        '_EventDataSource');

    // Debug recurring events specifically
    final recurringAppointments = source
        .where((a) => a.recurrenceRule != null && a.recurrenceRule!.isNotEmpty)
        .toList();
    AppLogger.debug(
        'Found ${recurringAppointments.length} recurring appointments:',
        '_EventDataSource');
    for (final appointment in recurringAppointments) {
      AppLogger.verbose(
          '  - "${appointment.title}": ${appointment.recurrenceRule}',
          '_EventDataSource');
      AppLogger.verbose(
          '    Start: ${appointment.startTime}, End: ${appointment.endTime}',
          '_EventDataSource');
      if (appointment.recurrenceExceptionDates != null) {
        AppLogger.verbose(
            '    Exception dates: ${appointment.recurrenceExceptionDates}',
            '_EventDataSource');
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
      AppLogger.verbose(
          'getRecurrenceRule for "${appointments![index].title}": "$rule"',
          '_EventDataSource');

      try {
        // Add RRULE: prefix if missing (backend may return just "FREQ=DAILY")
        String processedRule = rule;
        if (!processedRule.startsWith('RRULE:') && processedRule.contains('FREQ=')) {
          processedRule = 'RRULE:$processedRule';
          AppLogger.debug('Added RRULE: prefix: "$rule" -> "$processedRule"',
              '_EventDataSource');
        }

        // Fix malformed RRULE dates from backend (temporary until backend is updated)
        final fixedRule = _fixMalformedRRule(processedRule);
        if (fixedRule != processedRule) {
          AppLogger.debug('Fixed malformed RRULE: "$processedRule" -> "$fixedRule"',
              '_EventDataSource');
        }

        // Validate the RRULE format before returning
        if (_isValidRRule(fixedRule)) {
          return fixedRule;
        } else {
          AppLogger.debug('Invalid RRULE format, skipping: "$fixedRule"',
              '_EventDataSource');
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
        AppLogger.debug('Fixed malformed date: $datepart -> $fixedDate',
            '_EventDataSource');
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
