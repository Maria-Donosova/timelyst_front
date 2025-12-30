import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '../../../models/customApp.dart';
import '../../../models/calendars.dart';
import 'package:provider/provider.dart';
import '../../../providers/calendarProvider.dart';
import '../../../utils/rruleParser.dart';
import '../../../providers/eventProvider.dart';
import '../../../utils/eventsMapper.dart';
import '../../responsive/responsive_helper.dart';

/**
 * Method to build the UI for a single appointment.
 * It determines whether the appointment has a single day duration or a multi-day duration.
 * 
 * If the appointment has a single day duration, it displays a Card with the appointment details inside it.
 * If the appointment has a multi-day duration, it displays a colored rectangle with the appointment title on it.
 * 
 * @param context The context of the current widget.
 * @param calendarAppointmentDetails Details related to the appointment in the calendar.
 */
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  try {
    // Verify we have an appointment
    if (calendarAppointmentDetails.appointments.isEmpty) {
      return SizedBox();
    }

    final dynamic rawAppointment = calendarAppointmentDetails.appointments.first;
    CustomAppointment? customAppointment;

    // print('🔍 [AppointmentBuilder] Processing: ${rawAppointment.runtimeType}');

    if (rawAppointment is CustomAppointment) {
      customAppointment = rawAppointment;
      // print('   -> Is CustomAppointment: ${customAppointment.title} (ID: ${customAppointment.id})');
    } else if (rawAppointment is Appointment) {
      // Handle Syncfusion generated occurrence (Appointment object)
      // print('   -> Is Syncfusion Appointment: ${rawAppointment.subject} (ID: ${rawAppointment.id})');
      // We need to find the original master event to get custom properties
      try {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        // Syncfusion usually copies the ID if we override getId()
        final dynamic id = rawAppointment.id;
        
        if (id != null) {
          final masterEvent = eventProvider.events.firstWhere(
            (e) => e.id == id,
            orElse: () {
              // Fallback: Try to find in raw timeEvents (TimelystCalendarDataSource uses these)
              try {
                final timeEvent = eventProvider.timeEvents.firstWhere((e) => e.id == id);
                return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
              } catch (e) {
                return CustomAppointment(
                  id: 'temp', 
                  title: 'Unknown', 
                  startTime: rawAppointment.startTime, 
                  endTime: rawAppointment.endTime, 
                  isAllDay: rawAppointment.isAllDay,
                );
              }
            },
          );
          
          if (masterEvent.id != 'temp') {
            // print('      -> Found master: ${masterEvent.title}');
            // Create a synthetic CustomAppointment for this occurrence
            customAppointment = masterEvent.copyWith(
              startTime: rawAppointment.startTime,
              endTime: rawAppointment.endTime,
              isAllDay: rawAppointment.isAllDay,
            );
          } else {
             // print('      -> Master NOT found for ID: $id');
          }
        } else {
           // print('      -> ID is null on Appointment object');
        }
      } catch (e) {
        print('⚠️ [AppointmentBuilder] Error resolving master for occurrence: $e');
      }
    } else {
       print('⚠️ [AppointmentBuilder] Unknown type: ${rawAppointment.runtimeType}');
    }
    
    if (customAppointment == null) {
      // Fallback if we couldn't resolve it (should be rare with getId fixed)
      // Try to use what properties we can from the raw object if it's an Appointment
      if (rawAppointment is Appointment) {
         return Container(
           color: rawAppointment.color,
           child: Center(
             child: Text(
               rawAppointment.subject, 
               style: TextStyle(color: Colors.white, fontSize: 10),
               overflow: TextOverflow.ellipsis,
             )
           ),
         );
      }
      return SizedBox();
    }

    // Fix: Correctly check if start and end are on the same day
    bool isSameDay = customAppointment.startTime.year == customAppointment.endTime.year &&
        customAppointment.startTime.month == customAppointment.endTime.month &&
        customAppointment.startTime.day == customAppointment.endTime.day;

    // Calculate occurrence info string
    String? occurrenceString;
    // Wrap recurrence logic in try-catch to be safe
    try {
      if ((customAppointment.recurrenceRule != null && customAppointment.recurrenceRule!.isNotEmpty) ||
          (customAppointment.recurrenceId != null && customAppointment.recurrenceId!.isNotEmpty)) {
        
        // Only attempt parsing if we have a rule
        if (customAppointment.recurrenceRule != null && customAppointment.recurrenceRule!.isNotEmpty) {
             final rrule = customAppointment.recurrenceRule!;
             // Check RRuleParser availability
             try {
               final recurrenceInfo = RRuleParser.parseRRule(rrule);
               if (recurrenceInfo != null) {
                  final total = RRuleParser.getTotalOccurrences(rrule, customAppointment.startTime);
                  
                  final originalStart = customAppointment.originalStart;
                  final currentStart = customAppointment.startTime;
                  
                  final occurrenceNum = RRuleParser.calculateOccurrenceNumber(
                    eventStart: currentStart,
                    originalStart: originalStart, 
                    rrule: rrule,
                    seriesStart: customAppointment.timeEventInstance?.start ?? customAppointment.originalStart,
                  );
                  
                  if (occurrenceNum != null) {
                    if (total != null) {
                      occurrenceString = '$occurrenceNum/$total';
                    } else {
                      occurrenceString = '#$occurrenceNum';
                    }
                  }
               }
             } catch (e) {
               print('⚠️ [AppointmentBuilder] RRule parsing error: $e');
             }
        }
      }
    } catch (e) {
      print('⚠️ [AppointmentBuilder] Recurrence logic error: $e');
    }

    final width = MediaQuery.of(context).size.width;

    // Note: This appointmentBuilder is only used for day and week views in the calendar controller
    // so we can safely show source icons here. Month view uses monthCellBuilder which doesn't show icons.

    // Helper function to get the appropriate widget based on calendar source
    Widget _getCalendarSourceWidget(CustomAppointment appointment,
        {double size = 14, required Color color}) {
      
      try {
        // DEBUG: Trace why we are hitting default
        // print('🔍 [AppointmentBuilder] Checking icon for "${appointment.title}" (ID: ${appointment.id})');
        
        // First check the source map which should contain the most reliable information
        if (appointment.source != null && appointment.source!.isNotEmpty) {
          final sourceType =
              appointment.source!['type']?.toString().toLowerCase() ?? '';
          final sourceName =
              appointment.source!['name']?.toString().toLowerCase() ?? '';

          if (sourceType.contains('google') || sourceName.contains('google')) {
            return Icon(Icons.mail_outline, size: size, color: color);
          } else if (sourceType.contains('microsoft') ||
              sourceType.contains('outlook') ||
              sourceName.contains('microsoft') ||
              sourceName.contains('outlook')) {
            return Icon(Icons.window_outlined, size: size, color: color);
          } else if (sourceType.contains('apple') ||
              sourceType.contains('icloud') ||
              sourceName.contains('apple') ||
              sourceName.contains('icloud')) {
            return Icon(Icons.apple, size: size, color: color);
          }
        }

        // Check for specific calendar source IDs
        if (appointment.googleEventId != null &&
            appointment.googleEventId!.isNotEmpty) {
          return Icon(Icons.mail_outline, size: size, color: color);
        } else if (appointment.microsoftEventId != null &&
            appointment.microsoftEventId!.isNotEmpty) {
          return Icon(Icons.window_outlined, size: size, color: color);
        } else if (appointment.appleEventId != null &&
            appointment.appleEventId!.isNotEmpty) {
          return Icon(Icons.apple, size: size, color: color);
        }

        // Check sourceCalendar field for calendar name patterns
        if (appointment.sourceCalendar != null &&
            appointment.sourceCalendar!.isNotEmpty) {
          final sourceCalendarLower = appointment.sourceCalendar!.toLowerCase();

          if (sourceCalendarLower.contains('google')) {
            return Icon(Icons.mail_outline, size: size, color: color);
          } else if (sourceCalendarLower.contains('microsoft') ||
              sourceCalendarLower.contains('outlook')) {
            return Icon(Icons.window_outlined, size: size, color: color);
          } else if (sourceCalendarLower.contains('apple') ||
              sourceCalendarLower.contains('icloud') ||
              sourceCalendarLower.contains('caldav')) {
            return Icon(Icons.apple, size: size, color: color);
          }
        }

        // Check calendarId field as well
        if (appointment.calendarId != null &&
            appointment.calendarId!.isNotEmpty) {
          
          // Try to look up the calendar source from CalendarProvider
          try {
            final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
            final calendar = calendarProvider.getCalendarById(appointment.calendarId!);
            
            if (calendar != null) {
              // print('   - Provider found calendar: ${calendar.metadata.title}, source: ${calendar.source}');
              switch (calendar.source) {
                case CalendarSource.GOOGLE:
                  return Icon(Icons.mail_outline, size: size, color: color);
                case CalendarSource.MICROSOFT:
                  return Icon(Icons.window_outlined, size: size, color: color);
                case CalendarSource.APPLE:
                  return Icon(Icons.apple, size: size, color: color);
                default:
                  // Fall through to other checks
                  break;
              }
            }
          } catch (e) {
            // Ignore provider errors and fall back to string matching
          }
          
          final calendarIdLower = appointment.calendarId!.toLowerCase();

          if (calendarIdLower.contains('google')) {
            return Icon(Icons.mail_outline, size: size, color: color);
          } else if (calendarIdLower.contains('microsoft') ||
              calendarIdLower.contains('outlook')) {
            return Icon(Icons.window_outlined, size: size, color: color);
          } else if (calendarIdLower.contains('apple') ||
              calendarIdLower.contains('icloud') ||
              calendarIdLower.contains('caldav')) {
            return Icon(Icons.apple, size: size, color: color);
          }
        }

        // Check userCalendars field as it might contain calendar names
        if (appointment.userCalendars.isNotEmpty) {
          for (final calendar in appointment.userCalendars) {
            final calendarLower = calendar.toLowerCase();

            if (calendarLower.contains('google')) {
              return Icon(Icons.mail_outline, size: size, color: color);
            } else if (calendarLower.contains('microsoft') ||
                calendarLower.contains('outlook')) {
              return Icon(Icons.window_outlined, size: size, color: color);
            } else if (calendarLower.contains('apple') ||
                calendarLower.contains('icloud') ||
                calendarLower.contains('caldav')) {
              return Icon(Icons.apple, size: size, color: color);
            }
          }
        }

        // Default icon - Timelyst Logo
        return Image.asset(
          'assets/images/logos/timelyst_logo.png',
          width: size,
          height: size,
        );
      } catch (e) {
        print('⚠️ [AppointmentBuilder] Error getting source widget: $e');
        return SizedBox(width: size, height: size); // Return empty placeholder on error
      }
    }

    /**
     * If the appointment has a single day duration, return a Card with the appointment details
     */
    if (isSameDay && customAppointment.isAllDay == false) {
      final isSummary = customAppointment.title.startsWith('+') && customAppointment.groupedEvents != null;
      final Color indicatorColor = isSummary ? Colors.blue : catColor(customAppointment.catTitle);
      
      return Container(
        width: width,
        // Set the height of the Container to the height of the appointment in the calendar
        height: calendarAppointmentDetails.bounds.height,
        child: Card(
          elevation: isSummary ? 0 : 4, // More minimalist for summary
          color: isSummary ? Colors.transparent : null, // Clean look for summary
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customAppointment.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveValue(
                              context,
                              mobileValue: 10,
                              tabletValue: 12,
                              desktopValue: 14,
                            ),
                            color: isSummary ? Theme.of(context).textTheme.bodyLarge?.color : null,
                            fontWeight: isSummary ? FontWeight.bold : null,
                            fontStyle: customAppointment.title == 'Busy'
                                ? FontStyle.italic
                                : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSummary)
                       Text(
                        'Total: ${customAppointment.groupedEvents!.length + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
                      ),
                    if (occurrenceString != null)
                      Text(
                        occurrenceString,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                child: Align(
                  // Position the CircleAvatar at the top-left of the stack
                  alignment: Alignment(-1.0, -1.0),
                  child: CircleAvatar(
                    backgroundColor: indicatorColor,
                    radius: 2.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: indicatorColor,
                      width: 2.5, // Slightly thinner line as per screenshot
                      style: BorderStyle.solid,
                    ),
                  ),
                  shape: BoxShape.rectangle,
                ),
              ),
              // Calendar source icon in bottom right corner (shown for day/week views)
              if (!isSummary)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: _getCalendarSourceWidget(
                    customAppointment,
                    size: 14,
                    color:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                  ),
                ),
            ]),
          ),
        ),
      );
    }
    /**
     * If the appointment has a multi-day duration, return a colored rectangle with the appointment title
     */
    else {
      return Container(
        width: width,
        color: catColor(customAppointment.catTitle),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      customAppointment.title,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveValue(
                          context,
                          mobileValue: 10,
                          tabletValue: 12,
                          desktopValue: 14,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: customAppointment.title == 'Busy'
                            ? FontStyle.italic
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (occurrenceString != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0), // Make room for icon
                      child: Text(
                        occurrenceString,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Calendar source icon in bottom right corner for multi-day events (shown for day/week views)
            Positioned(
              right: 4,
              bottom: 4,
              child: _getCalendarSourceWidget(
                customAppointment,
                size: 14,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
  } catch (error) {
    return Text('Appointment cell builder error: $error');
  }
}
