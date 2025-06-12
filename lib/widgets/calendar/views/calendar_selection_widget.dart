import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../../models/calendars.dart';
//import '../../shared/categories.dart';

class CalendarSelectionWidget extends StatefulWidget {
  const CalendarSelectionWidget({
    Key? key,
  }) : super(key: key);

  @override
  _CalendarSelectionWidgetState createState() =>
      _CalendarSelectionWidgetState();
}

class _CalendarSelectionWidgetState extends State<CalendarSelectionWidget> {
  List<Calendar> _selectedCalendars = [];
  late CalendarProvider _calendarProvider;
  late AuthService _authService;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final userId = _authService.getUserId();
      await _calendarProvider.fetchCalendars(userId as String);
      setState(() {
        _selectedCalendars = List.from(_calendarProvider.calendars);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load calendars: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleCalendar(Calendar calendar, bool selected) {
    setState(() {
      if (selected) {
        _selectedCalendars.add(calendar);
      } else {
        _selectedCalendars.removeWhere((c) => c.id == calendar.id);
      }
    });
  }

  Widget _buildCategorySection(String category, List<Calendar> calendars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...calendars.map((calendar) => _buildCalendarTile(calendar)).toList(),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildCalendarTile(Calendar calendar) {
    final isSelected = _selectedCalendars.any((c) => c.id == calendar.id);
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Color(calendar.catColor as int),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        calendar.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => _toggleCalendar(calendar, value ?? false),
      ),
      onTap: () => _toggleCalendar(calendar, !isSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("entering calendar selection widget");
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    final groupedCalendars = <String, List<Calendar>>{};

    for (final calendar in _calendarProvider.calendars) {
      final category = calendar.category ?? 'Other';
      groupedCalendars.putIfAbsent(category, () => []).add(calendar);
    }

    return AlertDialog(
      title: Text('Select Calendars',
          style: Theme.of(context).textTheme.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedCalendars.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedCalendars
                      .map((calendar) => Chip(
                            label: Text(calendar.title),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _toggleCalendar(calendar, false),
                          ))
                      .toList(),
                ),
              ),
            ...groupedCalendars.entries
                .map((entry) => _buildCategorySection(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedCalendars),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

Future<List<Calendar>?> showCalendarSelectionDialog(
  BuildContext context,
) async {
  return await showDialog<List<Calendar>>(
    context: context,
    builder: (context) => const CalendarSelectionWidget(),
  );
}
