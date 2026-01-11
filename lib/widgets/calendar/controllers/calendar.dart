import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  Timer? _loadEventsDebounce;

  String? _headerText,
      _weekStart,
      _weekEnd,
      _month,
      _startTimeText,
      _endTimeText,
      _dateText,
      _cellDateText;
  double? width, cellWidth;
  DateTime? _lastBuildLogTime;

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

    // Initialize data source with empty list to handle initial loading state gracefully
    _dataSource = TimelystCalendarDataSource(
      events: [],
      occurrenceCounts: {},
    );
    
    // Note: Initial event loading will be handled by the onViewChanged callback
    // when the calendar first loads, so we don't need duplicate loading here
  }

  @override
  void dispose() {
    _loadEventsDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Loads events for the current visible date range using the new calendar view API
  /// with expand=true for pre-expanded occurrences
  Future<void> _loadEvents() async {
    if (_visibleDates.isEmpty) return;

    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Use new calendar view API with expand=true (default)
    await eventProvider.fetchCalendarView(
      startDate: _visibleDates.first,
      endDate: _visibleDates.last.add(const Duration(days: 1)),
    );

    // Get TimeEvent objects from provider (already expanded by backend)
    final timeEvents = eventProvider.timeEvents;
    
    // Build occurrence counts map from masters
    final occurrenceCounts = <String, int>{};
    for (final master in eventProvider.mastersMap.values) {
      occurrenceCounts[master.id] = eventProvider.getOccurrenceCount(master.id);
    }
    
    // Create simplified data source with flat event list
    double screenWidth = 0;
    try {
      screenWidth = MediaQuery.of(context).size.width;
    } catch (e) {
      LogService.warn('Calendar', 'Could not get screen width in _loadEvents: $e');
    }
    
    final cellWidth = screenWidth / 14;
    final isWeek = _controller.view == CalendarView.week;

    setState(() {
      _dataSource = TimelystCalendarDataSource(
        events: timeEvents,  // Flat list from backend
        occurrenceCounts: occurrenceCounts,
        summarizeWidth: isWeek && cellWidth > 0 ? cellWidth : null,
      );
    });
  }

  /// Refreshes the data source from EventProvider's current events list.
  /// Call this after optimistic updates to immediately reflect changes in the UI.
  void _refreshDataSource() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    // Use timeEvents (view-specific list) instead of all cached events
    // This ensures we only display events for the current calendar view
    final viewEvents = eventProvider.timeEvents;
    
    // Build occurrence counts map from masters
    final occurrenceCounts = <String, int>{};
    for (final master in eventProvider.mastersMap.values) {
      occurrenceCounts[master.id] = eventProvider.getOccurrenceCount(master.id);
    }
    
    double screenWidth = 0;
    try {
      screenWidth = MediaQuery.of(context).size.width;
    } catch (e) {
      // Ignore
    }
    
    final cellWidth = screenWidth / 14;
    final isWeek = _controller.view == CalendarView.week;

    setState(() {
      _dataSource = TimelystCalendarDataSource(
        events: viewEvents,
        occurrenceCounts: occurrenceCounts,
        summarizeWidth: isWeek && cellWidth > 0 ? cellWidth : null,
      );
    });
    
    LogService.info('Calendar', 'Data source refreshed with ${viewEvents.length} events');
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

    // Essential logging with debounce
    final now = DateTime.now();
    if (_lastBuildLogTime == null || now.difference(_lastBuildLogTime!) > const Duration(milliseconds: 100)) {
      _lastBuildLogTime = now;
      final appointmentsCount = _dataSource?.appointments?.length ?? 0;
      LogService.info('Calendar', 'Built calendar with $appointmentsCount appointments');
    }

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
                        dayNames: ResponsiveHelper.isMobile(context)
                            ? ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                            : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']),
                  )
                : isWeek
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getValue(context,
                                mobile: 8.0, tablet: 10.0, desktop: 12.0)),
                        child: WeekDaysW(
                            cellWidth: cellWidth,
                            dayNames: ResponsiveHelper.isMobile(context)
                                ? ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']),
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
                          MonthAppointmentDisplayMode.none,
                      showTrailingAndLeadingDates: false,
                    ),
                    appointmentBuilder: appointmentBuilder,
                    allowAppointmentResize: true,
                    allowDragAndDrop: true,
                    dragAndDropSettings:
                        DragAndDropSettings(showTimeIndicator: true),
                    dataSource: _dataSource,
                    onTap: _calendarTapped,
                    onDragEnd: _handleDragEnd,
                    onAppointmentResizeEnd: _handleResizeEnd,
                    onViewChanged: (ViewChangedDetails viewChangedDetails) {
                      // Track visible dates for _loadEvents
                      _visibleDates = viewChangedDetails.visibleDates;

                      final eventProvider =
                          Provider.of<EventProvider>(context, listen: false);

                      // REMOVED: Invalidate cache when view changes to ensure fresh data
                      // eventProvider.invalidateCache();
                      // print(
                      //     '📅 [Calendar] View changed - cache invalidated for fresh event data');

                      if (_controller.view == CalendarView.month) {
                        _headerText = DateFormat('yMMMM')
                            .format(viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2])
                            .toString();
                      }
                      if (_controller.view == CalendarView.week) {
                        final visibleDatesLength =
                            viewChangedDetails.visibleDates.length;
                        final firstDate = viewChangedDetails.visibleDates[0];
                        final middleDate = viewChangedDetails.visibleDates[
                                visibleDatesLength > 6
                                    ? 3 // Better middle for week view
                                    : visibleDatesLength ~/ 2];
                                    
                        _weekStart = DateFormat('d').format(firstDate).toString();
                        _weekEnd = DateFormat('d')
                            .format(viewChangedDetails.visibleDates[
                                visibleDatesLength > 6
                                    ? 6
                                    : visibleDatesLength - 1])
                            .toString();
                        _month = DateFormat('MMMM').format(middleDate).toString();
                        
                        // Robust string interpolation with null checks
                        _headerText = '${_month ?? ''} ${_weekStart ?? ''} - ${_weekEnd ?? ''}';
                      }
                      if (_controller.view == CalendarView.day) {
                        final middleDate = viewChangedDetails.visibleDates[
                                viewChangedDetails.visibleDates.length ~/ 2];
                        _headerText = DateFormat('MMMMEEEEd').format(middleDate).toString();
                      }

                      // Load events using the new calendar view API with debounce
                      _loadEventsDebounce?.cancel();
                      _loadEventsDebounce = Timer(const Duration(milliseconds: 300), () {
                        if (mounted) _loadEvents();
                      });

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
              _headerText ?? '',
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
                    // REMOVED: Invalidate cache when user manually switches views
                    // eventProvider.invalidateCache();
                    // print(
                    //     '📅 [Calendar] Manual switch to Today - cache invalidated for fresh event data');

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
                    // REMOVED: Invalidate cache when user manually switches views
                    // eventProvider.invalidateCache();
                    // print(
                    //     '📅 [Calendar] Manual view switch - cache invalidated for fresh event data');

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

          final appointmentToDisplay = _customAppointment;
          if (appointmentToDisplay == null) return;

          if (appointmentToDisplay.groupedEvents != null) {
            await _showSummaryDialog(appointmentToDisplay);
            return;
          }

          _dateText = DateFormat('MMMM d', 'en_US')
              .format(appointmentToDisplay.startTime)
              .toString();

          _startTimeText = DateFormat('hh:mm a')
              .format(appointmentToDisplay.startTime)
              .toString();

          _endTimeText =
              DateFormat('hh:mm a').format(appointmentToDisplay.endTime).toString();

          final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: EventDetails(
                    id: appointmentToDisplay.id,
                    subject: appointmentToDisplay.title,
                    dateText: _dateText,
                    start: _startTimeText,
                    end: _endTimeText,
                    catTitle: appointmentToDisplay.catTitle,
                    catColor: appointmentToDisplay.catColor,
                    participants: appointmentToDisplay.participants,
                    body: appointmentToDisplay.description,
                    location: appointmentToDisplay.location,
                    isAllDay: appointmentToDisplay.isAllDay,
                    recurrenceRule: appointmentToDisplay.recurrenceRule,
                    recurrenceId: appointmentToDisplay.recurrenceId,
                    originalStart: appointmentToDisplay.originalStart,
                    exDates: appointmentToDisplay.exDates,
                    initialStartTime: appointmentToDisplay.startTime,
                    initialEndTime: appointmentToDisplay.endTime,
                    calendarId: appointmentToDisplay.calendarId,
                  ),
                );
              });
          
          if (result == true) {
            setState(() {});
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
                initialStartTime: details.date,
                initialEndTime: details.date?.add(const Duration(minutes: 60)),
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
    // Comprehensive diagnostic logging
    final appointmentName = details.appointment is Appointment 
        ? (details.appointment as Appointment).subject 
        : (details.appointment is CustomAppointment ? (details.appointment as CustomAppointment).title : 'Unknown');
        
    LogService.info('Drag', 'START: $appointmentName');
    LogService.debug('Drag', 'Type: ${details.appointment?.runtimeType}');
    LogService.debug('Drag', 'ID: ${details.appointment is Appointment ? (details.appointment as Appointment).id : (details.appointment is CustomAppointment ? (details.appointment as CustomAppointment).id : "N/A")}');
    LogService.debug('Drag', 'New Time: ${details.droppingTime}');

    // Null safety: Syncfusion may provide null values in edge cases
    if (details.appointment == null || details.droppingTime == null) {
      LogService.warn('Drag', 'Cancelled - null appointment or droppingTime');
      return;
    }

    final droppingTime = details.droppingTime!;

    CustomAppointment? appointment;
    final dynamic rawAppointment = details.appointment!;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    if (rawAppointment is CustomAppointment) {
      appointment = rawAppointment;
    } else if (rawAppointment is Appointment) {
      // Multi-strategy resolution for when Syncfusion returns Appointment instead of CustomAppointment
      LogService.debug('Calendar', 'Drag: Syncfusion returned Appointment, attempting resolution...');
      
      // Strategy 1: Resolve by ID
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
          LogService.info('Drag', 'Resolved by ID: ${master.id}');
        }
      }
      
      // Strategy 2: Match by time + title
      if (appointment == null) {
        final match = eventProvider.events.firstWhere(
          (e) => e.startTime == rawAppointment.startTime && e.title == rawAppointment.subject,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (match.id != 'temp') {
          appointment = match.copyWith(
            startTime: rawAppointment.startTime, 
            endTime: rawAppointment.endTime,
          );
          LogService.info('Drag', 'Resolved by time+title: ${match.id}');
        }
      }
      
      // Strategy 3: Match by title only (less precise, last resort)
      if (appointment == null) {
        final match = eventProvider.events.firstWhere(
          (e) => e.title == rawAppointment.subject,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (match.id != 'temp') {
          appointment = match.copyWith(
            startTime: rawAppointment.startTime, 
            endTime: rawAppointment.endTime,
          );
          LogService.info('Drag', 'Resolved by title-only: ${match.id}');
        }
      }
      
      // Strategy 4: Match by recurrenceId if present
      if (appointment == null && rawAppointment.recurrenceId != null) {
        final masterId = rawAppointment.recurrenceId.toString();
        final master = eventProvider.events.firstWhere(
          (e) => e.id == masterId || e.recurrenceId == masterId,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (master.id != 'temp') {
          appointment = master.copyWith(
            startTime: rawAppointment.startTime,
            endTime: rawAppointment.endTime,
          );
          print('🖱️ [Drag] Resolved by recurrenceId: ${master.id}');
        }
      }
    }
    
    // Comprehensive null check with user-facing error
    if (appointment == null) {
      LogService.error('Calendar', 'Drag: Failed to resolve appointment from Syncfusion data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to move event. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    LogService.debug(
        'Calendar', 'Handling drag-and-drop for appointment: ${appointment.title}');

    // Calculate the duration of the event
    final duration = appointment.endTime.difference(appointment.startTime);

    if (appointment.isRecurring) {
      // Handle recurring event with EventHandlerService
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authToken = await authProvider.authService.getAuthToken();

      if (authToken == null) {
        LogService.error('Calendar', 'No auth token available for drag-and-drop');
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
          newStartTime: droppingTime,
          eventDuration: duration,
          totalOccurrences: occurrenceCount,
        );

        // Refresh calendar after successful update
        await _loadEvents();
      } catch (e) {
        LogService.error('Calendar', 'Error handling recurring event drag-and-drop', e);
        
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
      // for non-recurring event - simple update
      // for all-day events, ensure proper midnight-to-midnight format
      DateTime newStart = droppingTime;
      DateTime newEnd = droppingTime.add(duration);
      
      if (appointment.isAllDay) {
        // Normalize to start of day for all-day events
        newStart = DateTime(newStart.year, newStart.month, newStart.day);
        // End must be exactly one day after start for single-day all-day events
        final daysDuration = appointment.endTime.difference(appointment.startTime).inDays;
        newEnd = newStart.add(Duration(days: daysDuration > 0 ? daysDuration : 1));
      }
      
      final updatedAppointment = CustomAppointment(
        id: appointment.id,
        title: appointment.title,
        description: appointment.description,
        startTime: newStart,
        endTime: newEnd,
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

      // Optimistic UI update with rollback capability
      final rollback = eventProvider.optimisticUpdateEvent(
        appointment.id, 
        updatedAppointment,
      );
      _refreshDataSource();

      // Persist to backend
      LogService.info('Drag', 'Starting backend update for: ${appointment.id}');
      try {
        final eventPayload = _createEventPayload(updatedAppointment);
        LogService.info('Drag', 'Payload created, calling updateEvent...');
        final result = await eventProvider.updateEvent(
          appointment.id,
          eventPayload,
        );

        if (result == null) {
          throw Exception('Update returned null');
        }

        LogService.info('Drag', 'Backend update successful');
        // Second refresh to ensure UI is fully in sync after backend confirms
        _refreshDataSource();
      } catch (e) {
        LogService.error('Drag', 'Backend update failed', e);
        
        // Rollback on error
        rollback();
        _refreshDataSource();

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
    // Comprehensive diagnostic logging
    final appointmentName = details.appointment is Appointment 
        ? (details.appointment as Appointment).subject 
        : (details.appointment is CustomAppointment ? (details.appointment as CustomAppointment).title : 'Unknown');

    LogService.info('Resize', 'START: $appointmentName');
    LogService.debug('Resize', 'Type: ${details.appointment?.runtimeType}');
    LogService.debug('Resize', 'ID: ${details.appointment is Appointment ? (details.appointment as Appointment).id : (details.appointment is CustomAppointment ? (details.appointment as CustomAppointment).id : "N/A")}');
    LogService.debug('Resize', 'Range: ${details.startTime} -> ${details.endTime}');

    // (rapid gestures, widget disposal during resize)
    if (details.appointment == null || 
        details.startTime == null || 
        details.endTime == null) {
      LogService.warn('Resize', 'Cancelled - null values');
      return;
    }

    final startTime = details.startTime!;
    final endTime = details.endTime!;

    CustomAppointment? appointment;
    final dynamic rawAppointment = details.appointment!;
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (rawAppointment is CustomAppointment) {
      appointment = rawAppointment;
    } else if (rawAppointment is Appointment) {
      // Multi-strategy resolution for when Syncfusion returns Appointment instead of CustomAppointment
      LogService.debug('Calendar', 'Resize: Syncfusion returned Appointment, attempting resolution...');
      
      // Strategy 1: Resolve by ID
      if (rawAppointment.id != null) {
        final master = eventProvider.events.firstWhere(
          (e) => e.id == rawAppointment.id,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (master.id != 'temp') {
          appointment = master;
          LogService.info('Resize', 'Resolved by ID: ${master.id}');
        }
      }
      
      // Strategy 2: Match by time + title
      if (appointment == null) {
        final match = eventProvider.events.firstWhere(
          (e) => e.startTime == rawAppointment.startTime && e.title == rawAppointment.subject,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (match.id != 'temp') {
          appointment = match;
          LogService.info('Resize', 'Resolved by time+title: ${match.id}');
        }
      }
      
      // Strategy 3: Match by title only (less precise, last resort)
      if (appointment == null) {
        final match = eventProvider.events.firstWhere(
          (e) => e.title == rawAppointment.subject,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (match.id != 'temp') {
          appointment = match;
          LogService.info('Resize', 'Resolved by title-only: ${match.id}');
        }
      }
      
      // Strategy 4: Match by recurrenceId if present
      if (appointment == null && rawAppointment.recurrenceId != null) {
        final masterId = rawAppointment.recurrenceId.toString();
        final master = eventProvider.events.firstWhere(
          (e) => e.id == masterId || e.recurrenceId == masterId,
          orElse: () => CustomAppointment(id: 'temp', title: 'Unknown', startTime: rawAppointment.startTime, endTime: rawAppointment.endTime, isAllDay: rawAppointment.isAllDay),
        );
        if (master.id != 'temp') {
          appointment = master.copyWith(
            startTime: rawAppointment.startTime,
            endTime: rawAppointment.endTime,
          );
          LogService.info('Resize', 'Resolved by recurrenceId: ${master.id}');
        }
      }
    }

    // Comprehensive null check with user-facing error
    if (appointment == null) {
      LogService.error('Calendar', 'Resize: Failed to resolve appointment from Syncfusion data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to resize event. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    LogService.info('Resize', 'Handling: ${appointment.title} (isRecurring: ${appointment.isRecurring})');

    if (appointment.isRecurring) {
      // Handle recurring event with EventHandlerService
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authToken = await authProvider.authService.getAuthToken();

      if (authToken == null) {
        LogService.error('Calendar', 'No auth token available for resize');
        return;
      }

      final handler = EventHandlerService(authToken: authToken);

      // Get master ID and occurrence count
      final masterId = appointment.recurrenceId ?? appointment.id;
      final occurrenceCount = eventProvider.getOccurrenceCount(masterId);

      // Build update payload with new times
      final updates = {
        'start': startTime.toUtc().toIso8601String(),
        'end': endTime.toUtc().toIso8601String(),
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
        LogService.error('Calendar', 'Error handling recurring event resize', e);
        
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
      // For all-day events, ensure proper midnight-to-midnight format
      DateTime newStart = startTime;
      DateTime newEnd = endTime;
      
      if (appointment.isAllDay) {
        // Normalize to start of day for all-day events
        newStart = DateTime(newStart.year, newStart.month, newStart.day);
        // End must be start of next day (midnight format)
        newEnd = DateTime(newEnd.year, newEnd.month, newEnd.day);
        // If end equals start, add 1 day (minimum 1-day all-day event)
        if (newEnd.isBefore(newStart) || newEnd.isAtSameMomentAs(newStart)) {
          newEnd = newStart.add(const Duration(days: 1));
        }
      }
      
      final updatedAppointment = CustomAppointment(
        id: appointment.id,
        title: appointment.title,
        description: appointment.description,
        startTime: newStart,
        endTime: newEnd,
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

      // Optimistic UI update with rollback capability
      final rollback = eventProvider.optimisticUpdateEvent(
        appointment.id, 
        updatedAppointment,
      );
      _refreshDataSource();

      // Persist to backend
      LogService.info('Resize', 'Starting backend update for: ${appointment.id}');
      try {
        final eventPayload = _createEventPayload(updatedAppointment);
        LogService.info('Resize', 'Payload created, calling updateEvent...');
        final result = await eventProvider.updateEvent(
          appointment.id,
          eventPayload,
        );

        if (result == null) {
          throw Exception('Update returned null');
        }

        LogService.info('Resize', 'Backend update successful');
        // Second refresh to ensure UI is fully in sync after backend confirms
        _refreshDataSource();
      } catch (e) {
        LogService.error('Resize', 'Backend update failed', e);
        
        // Rollback on error
        rollback();
        _refreshDataSource();

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

  Future<void> _showSummaryDialog(CustomAppointment summary) async {
    final events = summary.groupedEvents ?? [];
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Events at ${DateFormat('jm').format(summary.startTime)}'),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 6,
                  backgroundColor: event.catColor,
                ),
                title: Text(event.title),
                subtitle: Text('${DateFormat('jm').format(event.startTime)} - ${DateFormat('jm').format(event.endTime)}'),
                onTap: () async {
                  Navigator.pop(context);
                  // Trigger a re-tap on the specific event to show its details
                  // Since SfCalendar expects a CalendarTapDetails which we don't have easily,
                  // we can just directly show the EventDetails dialog.
                  final dateText = DateFormat('MMMM d', 'en_US').format(event.startTime).toString();
                  final startText = DateFormat('hh:mm a').format(event.startTime).toString();
                  final endText = DateFormat('hh:mm a').format(event.endTime).toString();

                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: EventDetails(
                        id: event.id,
                        subject: event.title,
                        dateText: dateText,
                        start: startText,
                        end: endText,
                        catTitle: event.catTitle,
                        catColor: event.catColor,
                        participants: event.participants,
                        body: event.description,
                        location: event.location,
                        isAllDay: event.isAllDay,
                        recurrenceRule: event.recurrenceRule,
                        recurrenceId: event.recurrenceId,
                        originalStart: event.originalStart,
                        exDates: event.exDates,
                        calendarId: event.calendarId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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


