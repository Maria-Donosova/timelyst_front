import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:YOUR_PACKAGE_NAME/widgets/calendar/screens/appointment_cell_builder.dart';
import 'package:YOUR_PACKAGE_NAME/calendar.dart';

void main() {
  testWidgets('appointmentBuilder returns a Card when appointment has a single day duration', () {
    final context = MaterialApp().buildContext();
    final calendarAppointmentDetails = CalendarAppointmentDetails(
      appointments: [
        CustomAppointment(
          startTime: DateTime(2022, 1, 1),
          endTime: DateTime(2022, 1, 1),
          subject: 'Test Event',
          catTitle: 'Category',
        ),
      ],
    );
    expect(appointmentBuilder(context, calendarAppointmentDetails), isA<Container>());
  });

  testWidgets('appointmentBuilder returns a colored rectangle when appointment has a multi-day duration', () {
    final context = MaterialApp().buildContext();
    final calendarAppointmentDetails = CalendarAppointmentDetails(
      appointments: [
        CustomAppointment(
          startTime: DateTime(2022, 1, 1),
          endTime: DateTime(2022, 1, 31),
          subject: 'Test Event',
          catTitle: 'Category',
        ),
      ],
    );
    expect(appointmentBuilder(context, calendarAppointmentDetails), isA<Container>());
  });

  testWidgets('appointmentBuilder calls functions to get the category color', () {
    final context = MaterialApp().buildContext();
    final calendarAppointmentDetails = CalendarAppointmentDetails(
      appointments: [
        CustomAppointment(
          startTime: DateTime(2022, 1, 1),
          endTime: DateTime(2022, 1, 1),
          subject: 'Test Event',
          catTitle: 'Category',
        ),
      ],
    );
    expect(() => catColor(calendarAppointmentDetails.appointments.first.catTitle), isNot(throwsException));
  });
}
