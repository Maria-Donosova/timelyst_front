import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/widgets/calendar/controllers/calendar.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:timelyst_flutter/models/customApp.dart';

class MockEventProvider extends Mock implements EventProvider {
  @override
  List<CustomAppointment> get events => [];
  
  @override
  bool get isLoading => false;

  @override
  void invalidateCache() {}
  
  @override
  Future<void> fetchMonthViewEvents({DateTime? month}) async {}
  
  @override
  Future<void> fetchWeekViewEvents({DateTime? weekStart}) async {}
  
  @override
  Future<void> fetchDayViewEvents({DateTime? date, bool isParallelLoad = false}) async {}
}

void main() {
  testWidgets('Calendar header has Today icon button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EventProvider>(
          create: (_) => MockEventProvider(),
          child: const Scaffold(
            body: CalendarW(),
          ),
        ),
      ),
    );

    // Verify that the Today icon is present
    expect(find.byIcon(Icons.today), findsOneWidget);
    expect(find.byTooltip('Today'), findsOneWidget);

    // Tap the Today icon
    await tester.tap(find.byIcon(Icons.today));
    await tester.pump();

    // Verify that the view switched to Day view (this is harder to verify directly without inspecting the controller state, 
    // but ensuring no crash and button existence is a good start)
  });
}
