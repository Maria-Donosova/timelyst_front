import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendarProvider.dart';
import '../../models/calendars.dart';

/// A screen that allows the user to select one or more calendars from a list.
class CalendarSelectionScreen extends StatefulWidget {
  final List<Calendar> calendars;
  final List<Calendar> initiallySelectedCalendars;

  const CalendarSelectionScreen({
    required this.calendars,
    this.initiallySelectedCalendars = const [],
  });

  @override
  State<CalendarSelectionScreen> createState() =>
      _CalendarSelectionScreenState();
}

class _CalendarSelectionScreenState extends State<CalendarSelectionScreen> {
  late final List<Calendar> _selectedCalendars;

  @override
  void initState() {
    super.initState();
    // Initialize the list of selected calendars with the initial values.
    _selectedCalendars = List.from(widget.initiallySelectedCalendars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Calendars'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedCalendars),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.calendars.length,
        itemBuilder: (context, index) {
          final calendar = widget.calendars[index];
          final isSelected = _selectedCalendars.any((c) => c.id == calendar.id);
          return CheckboxListTile(
            title: Text(calendar.metadata.title),
            subtitle: Text(calendar.metadata.description ?? ''),
            value: isSelected,
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedCalendars.add(calendar);
                } else {
                  _selectedCalendars.removeWhere((c) => c.id == calendar.id);
                }
              });
            },
          );
        },
      ),
    );
  }
}

/// Shows a dialog to select calendars.
///
/// Fetches all calendars from [CalendarProvider] and displays
/// [CalendarSelectionScreen].
/// Returns a list of selected [Calendar] objects, or `null` if the
/// dialog is dismissed.
Future<List<Calendar>?> showCalendarSelectionDialog(
  BuildContext context, {
  List<Calendar> selectedCalendars = const [],
}) async {
  final calendarProvider =
      Provider.of<CalendarProvider>(context, listen: false);
  final allCalendars = calendarProvider.calendars;

  return await Navigator.of(context).push<List<Calendar>>(
    MaterialPageRoute(
      builder: (context) => CalendarSelectionScreen(
        calendars: allCalendars,
        initiallySelectedCalendars: selectedCalendars,
      ),
    ),
  );
}
