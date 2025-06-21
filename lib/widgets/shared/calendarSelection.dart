import 'package:flutter/material.dart';
import '../../apis/googleIntegration/googleOrchestrator.dart';
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
    print("Enter calendar selection screen");
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Calendars'),
      ),
      body: ListView.builder(
        itemCount: widget.calendars.length,
        itemBuilder: (context, index) {
          final calendar = widget.calendars[index];
          return CheckboxListTile(
            title: Text(calendar.metadata.title),
            subtitle: Text(calendar.metadata.description ?? ''),
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
      floatingActionButton: ElevatedButton(
        child: Text('Save Selected Calendars',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            )),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () async {
          if (_selectedCalendars.isNotEmpty) {
            //try {
            // Save selected calendars using the orchestrator
            // await GoogleOrchestrator().saveSelectedCalendars(
            //     widget.userId, widget.email, _selectedCalendars);
            // print("Widget User ID: ${widget.userId}");
            // print("Widget email: ${widget.email}");

            var result = await GoogleOrchestrator().saveSelectedCalendars(
                widget.userId, widget.email, _selectedCalendars);
            print("Widget User ID: ${widget.userId}");
            print("Widget email: ${widget.email}");

            if (result != null) {
              if (result['success'] == true) {
                // Show a success message in the SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        result['message'] ?? 'Calendars saved successfully!'),
                    backgroundColor:
                        Colors.green, // Optional: Use green for success
                  ),
                );
              } else {
                // Show an error message in the SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(result['message'] ?? 'Failed to save calendars.'),
                    backgroundColor: Colors.red, // Optional: Use red for errors
                  ),
                );
              }
            } else {
              // Handle the case where result is null
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('An unexpected error occurred.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        //child: Icon(Icons.save),
      ),
    );
  }
}
