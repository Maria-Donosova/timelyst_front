import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/widgets/calendar/models/calendar_model.dart';
import 'package:timelyst_flutter/widgets/calendar/views/appointment_details.dart';

void main() {
  group('EventDetails Widget Tests', () {
    late EventDetails eventDetails;

    setUp(() {
      eventDetails = EventDetails(
        id: '1',
        userCalendars: [
          Calendars(
            calendarId: '1',
            calendarSource: 'Google',
            calendarName: 'Family',
            email: 'test@gmail.com',
            password: 'password',
            category: 'Kids',
            events: [],
            dateImported: DateTime.now(),
            dateCreated: DateTime.now(),
            dateUpdated: DateTime.now(),
          ),
        ],
        subject: 'Meeting',
        dateText: 'January 1',
        startTime: '10:00',
        endTime: '11:00',
        isAllDay: false,
        recurrenceRule: 'None',
        catTitle: 'Work',
        catColor: Colors.blue,
        participants: 'test@gmail.com',
        body: 'Meeting description',
        location: 'Office',
      );
    });

    testWidgets('should display initial event details',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      expect(find.text('Meeting'), findsOneWidget);
      expect(find.text('January 1'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('11:00'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('test@gmail.com'), findsOneWidget);
      expect(find.text('Meeting description'), findsOneWidget);
    });

    testWidgets('should update date when date is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      await tester.tap(find.text('January 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15')); // Select 15th day of the month
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('January 15'), findsOneWidget);
    });

    testWidgets('should update start and end time when time is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.tap(find.text('30'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('11:00'),
          findsOneWidget); // End time should be updated by 30 minutes
    });

    testWidgets('should update all day event times',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      await tester.tap(find.byIcon(Icons.hourglass_empty_rounded));
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('23:59'), findsOneWidget);
    });

    testWidgets('should update recurrence rule', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      await tester.tap(find.byIcon(Icons.event_repeat_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('should validate email format for participants',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: eventDetails)));

      await tester.enterText(find.byType(TextFormField).at(5), 'invalid-email');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
