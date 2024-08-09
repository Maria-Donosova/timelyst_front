import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/user_calendar.dart';
import '../../models/user_profile.dart';

import '../shared/categories.dart';

class CustomAppointment extends Appointment {
  final String creator;
  final String eventOrganizer;
  // List<UserProfile> userProfiles;
  // List<UserCalendar> userCalendars;
  DateTime? dateText;
  // bool reminder;
  // bool holiday;
  final String catTitle;
  final Color catColor;
  final String participants;
  String? eventBody;
  // List<DateTime>? exceptionDates;
  // DateTime dateCreated;
  // DateTime dateChanged;

  CustomAppointment({
    this.creator = 'Maria',
    // List<UserProfile> userProfiles = '',
    // List<UserCalendar> userCalendars = '',
    required DateTime startTime,
    required DateTime endTime,
    required this.eventOrganizer,
    String? subject,
    Color? color,
    bool isAllDay = false,
    String? startTimeZone,
    String? endTimeZone,
    String? recurrenceRule,
    List<DateTime>? recurrenceExceptionDates,
    Object? recurrenceId,
    String? notes,
    String? location,
    List<Object>? resourceIds,
    required this.catTitle,
    required this.catColor,
    this.participants = '',
  }) : super(
          startTime: startTime,
          endTime: endTime,
          subject: subject ?? '',
          color: color ?? Colors.blue,
          isAllDay: isAllDay,
          startTimeZone: startTimeZone,
          endTimeZone: endTimeZone,
          recurrenceRule: recurrenceRule,
          recurrenceExceptionDates: recurrenceExceptionDates,
          recurrenceId: recurrenceId,
          notes: notes,
          location: location,
          resourceIds: resourceIds,
        );
}

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;

  final categoryColor = appointment.color;

  //final selectedCategory = 'Friends';
//  final categoryColor = catColor(selectedCategory);

  final width = MediaQuery.of(context).size.width;

  return Container(
      width: width,
      height: calendarAppointmentDetails.bounds.height,
      child: Card(
        elevation: 4,
        child: InkWell(
          splashColor: Colors.blueGrey.withAlpha(30),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                appointment.subject,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              child: Align(
                alignment: Alignment(-1.005, -1.05),
                child: CircleAvatar(
                  backgroundColor: categoryColor,
                  radius: 3.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: categoryColor,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ]),
        ),
      ));
}
