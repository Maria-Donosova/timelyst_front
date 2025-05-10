import 'package:flutter/material.dart';
import '../../../models/calendars.dart';
import '../../shared/categories.dart';

class CalendarSelectionWidget extends StatefulWidget {
  final List<Calendar> calendars;
  final Map<String, bool>? initialSelection;

  const CalendarSelectionWidget({
    Key? key,
    required this.calendars,
    this.initialSelection,
  }) : super(key: key);

  @override
  State<CalendarSelectionWidget> createState() =>
      _CalendarSelectionWidgetState();
}

class _CalendarSelectionWidgetState extends State<CalendarSelectionWidget> {
  late Map<String, bool> _checkedCalendars;
  late Set<String> _uniqueCategories;
  late Map<String, List<Calendar>> _categoryCalendarsMap;

  @override
  void initState() {
    super.initState();
    _checkedCalendars = widget.initialSelection ?? {};
    _uniqueCategories = {};
    _categoryCalendarsMap = {};

    // Populate the Set and Map with unique categories and their calendars
    for (var calendar in widget.calendars) {
      final category = calendar.category;

      if (!_uniqueCategories.contains(category)) {
        _uniqueCategories.add(category!);
        _categoryCalendarsMap[category] = []; // Initialize with an empty list
      }
      _categoryCalendarsMap[category]!.add(calendar);

      // Initialize checked state if not already set
      if (!_checkedCalendars.containsKey(calendar.title)) {
        _checkedCalendars[calendar.title] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('Calendars', style: Theme.of(context).textTheme.displayMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _uniqueCategories.map((category) {
            final categoryCalendars = _categoryCalendarsMap[category]!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: catColor(category),
                      radius: 4.5,
                    ),
                  ],
                ),
                if (categoryCalendars.isNotEmpty)
                  Column(
                    children: categoryCalendars.map((calendar) {
                      return Tooltip(
                        message: calendar.user,
                        child: CheckboxListTile(
                          title: Text(
                            calendar.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _checkedCalendars[calendar.title],
                          onChanged: (bool? value) {
                            setState(() {
                              _checkedCalendars[calendar.title] = value!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary),
          child: Text('Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary),
          child: Text('Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
          onPressed: () {
            Navigator.of(context).pop(_checkedCalendars);
          },
        ),
      ],
    );
  }
}

// Helper function to show the calendar selection dialog
Future<Map<String, bool>?> showCalendarSelectionDialog(
    BuildContext context, List<Calendar> calendars,
    {Map<String, bool>? initialSelection}) async {
  return await showDialog<Map<String, bool>>(
    context: context,
    builder: (BuildContext context) {
      return CalendarSelectionWidget(
        calendars: calendars,
        initialSelection: initialSelection,
      );
    },
  );
}
