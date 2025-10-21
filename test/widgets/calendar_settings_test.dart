import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/widgets/screens/common/calendarSettings.dart';
import 'package:timelyst_flutter/models/calendars.dart';

void main() {
  testWidgets('None hint shown and selecting None clears import flags', (WidgetTester tester) async {
    // Create a sample calendar with various import flags set
    final calendar = Calendar(
      id: '1',
      userId: 'user1',
      source: CalendarSource.google,
      providerCalendarId: 'prov1',
      email: 'a@b.com',
      isSelected: true,
      isPrimary: false,
      metadata: CalendarMetadata(
        title: 'Test Calendar',
        color: const Color(0xFFA4BDFC),
      ),
      preferences: CalendarPreferences(
        importSettings: CalendarImportSettings(
          importAll: false,
          importSubject: true,
          importBody: true,
          importConferenceInfo: true,
          importOrganizer: true,
          importRecipients: true,
        ),
      ),
      sync: CalendarSyncInfo(),
    );

    await tester.pumpWidget(MaterialApp(
      home: CalendarSettings(
        calendars: [calendar],
        userId: 'user1',
        email: 'a@b.com',
      ),
    ));

    // Hint text should be present
    expect(find.textContaining('only start and end times will be imported'), findsOneWidget);

    // Tap the 'None' checkbox
    final noneFinder = find.widgetWithText(Row, 'None');
    expect(noneFinder, findsOneWidget);

    // Find the Checkbox inside that Row and tap it
    final checkboxFinder = find.descendant(of: noneFinder, matching: find.byType(Checkbox));
    expect(checkboxFinder, findsOneWidget);

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Verify the calendar in the widget tree has all import flags false
    final stateful = tester.state(find.byType(CalendarSettings)) as State<CalendarSettings>;
  final widgetState = stateful.widget;
  final updated = widgetState.calendars.first;

    expect(updated.preferences.importSettings.importAll, isFalse);
    expect(updated.preferences.importSettings.importSubject, isFalse);
    expect(updated.preferences.importSettings.importBody, isFalse);
    expect(updated.preferences.importSettings.importConferenceInfo, isFalse);
    expect(updated.preferences.importSettings.importOrganizer, isFalse);
    expect(updated.preferences.importSettings.importRecipients, isFalse);
  });
}
