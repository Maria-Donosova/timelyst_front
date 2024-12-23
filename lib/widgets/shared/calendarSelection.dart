import 'package:flutter/material.dart';
import '../../services/googleIntegration/googleOrchestrator.dart';
import '../../models/calendars.dart';

class CalendarSelectionScreen extends StatefulWidget {
  final String userId;
  final String email;
  final List<Calendar> calendars;

  const CalendarSelectionScreen({
    required this.userId,
    required this.email,
    required this.calendars,
  });

  @override
  _CalendarSelectionScreenState createState() =>
      _CalendarSelectionScreenState();
}

class _CalendarSelectionScreenState extends State<CalendarSelectionScreen> {
  List<Calendar> _selectedCalendars = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Calendars'),
      ),
      body: ListView.builder(
        itemCount: widget.calendars.length,
        itemBuilder: (context, index) {
          final calendar = widget.calendars[index];
          return CheckboxListTile(
            title: Text(calendar.title),
            subtitle: Text(calendar.description),
            value: _selectedCalendars.contains(calendar),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected!) {
                  _selectedCalendars.add(calendar);
                } else {
                  _selectedCalendars.remove(calendar);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_selectedCalendars.isNotEmpty) {
            try {
              // Save selected calendars using the orchestrator
              await GoogleOrchestrator()
                  .saveSelectedCalendars(widget.userId, _selectedCalendars);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calendars saved successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save calendars: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No calendars selected.')),
            );
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
