import 'package:flutter/material.dart';
import '../../../models/calendars.dart';
import '../../shared/categories.dart';

class CalendarSelectionWidget extends StatefulWidget {
  final List<Calendar> calendars;
  final Map<String, bool>? initialSelectedCalendars;

  const CalendarSelectionWidget({
    Key? key,
    required this.calendars,
    this.initialSelectedCalendars,
  }) : super(key: key);

  @override
  _CalendarSelectionWidgetState createState() =>
      _CalendarSelectionWidgetState();
}

class _CalendarSelectionWidgetState extends State<CalendarSelectionWidget> {
  late Map<String, bool> _selectedCalendars;

  @override
  void initState() {
    super.initState();
    _selectedCalendars =
        Map<String, bool>.from(widget.initialSelectedCalendars ?? {});
    // Ensure all calendars have an entry, defaulting to false if not in initialSelectedCalendars
    for (var calendar in widget.calendars) {
      _selectedCalendars.putIfAbsent(calendar.id!, () => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group calendars by category
    Map<String, List<Calendar>> groupedCalendars = {};
    for (var calendar in widget.calendars) {
      String category = calendar.category ?? 'Uncategorized';
      if (!groupedCalendars.containsKey(category)) {
        groupedCalendars[category] = [];
      }
      groupedCalendars[category]!.add(calendar);
    }

    return AlertDialog(
      title: Text('Select Calendar(s)',
          style: Theme.of(context).textTheme.displayMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: groupedCalendars.entries.map((entry) {
            String category = entry.key;
            List<Calendar> calendarsInCategory = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...calendarsInCategory.map((calendar) {
                  return CheckboxListTile(
                    title: Text(calendar.title), // Displays calendar name
                    value: _selectedCalendars[calendar.id!],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedCalendars[calendar.id!] = value!;
                      });
                    },
                  );
                }).toList(),
                Divider(),
              ],
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(_selectedCalendars);
          },
        ),
      ],
    );
  }
}

// Helper function to show the calendar selection dialog
Future<Map<String, bool>?> showCalendarSelectionDialog(
    BuildContext context, List<Calendar> calendars,
    // Stylistic suggestion: consider renaming for consistency with the widget's parameter
    // {Map<String, bool>? initialSelectedCalendars}) async {
    {Map<String, bool>? initialSelection}) async {
  return await showDialog<Map<String, bool>>(
    context: context,
    builder: (BuildContext context) {
      return CalendarSelectionWidget(
        calendars: calendars,
        // initialSelectedCalendars: initialSelectedCalendars, // if renamed above
        initialSelectedCalendars: initialSelection,
      );
    },
  );
}
