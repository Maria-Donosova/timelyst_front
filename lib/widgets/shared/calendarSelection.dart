import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendarProvider.dart';
import '../../models/calendars.dart';

/// A screen that allows the user to select one or more calendars from a list,
/// grouped by category for better organization.
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

  /// Adds or removes a calendar from the list of selected calendars.
  void _toggleCalendar(Calendar calendar, bool selected) {
    setState(() {
      if (selected) {
        _selectedCalendars.add(calendar);
      } else {
        _selectedCalendars.removeWhere((c) => c.id == calendar.id);
      }
    });
  }

  /// Builds a UI section for a specific category of calendars.
  Widget _buildCategorySection(String category, List<Calendar> calendars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          child: Text(
            category.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.7),
                  letterSpacing: 1.2,
                ),
          ),
        ),
        ...calendars.map((calendar) {
          final isSelected = _selectedCalendars.any((c) => c.id == calendar.id);
          final source = calendar.source.toString().split('.').last;
          return CheckboxListTile(
            title: Text(calendar.metadata.title),
            subtitle: Text(source[0].toUpperCase() + source.substring(1)),
            value: isSelected,
            onChanged: (bool? value) {
              if (value != null) {
                _toggleCalendar(calendar, value);
              }
            },
            activeColor: Theme.of(context).primaryColor,
          );
        }).toList(),
        const Divider(height: 24),
      ],
    );
  }

  /// Builds a wrap of chips for the currently selected calendars.
  Widget _buildSelectedChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedCalendars
            .map((calendar) => Chip(
                  label: Text(
                    calendar.metadata.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onDeleted: () => _toggleCalendar(calendar, false),
                ))
            .toList(),
      ),
    );
  }

  /// Builds the UI to be displayed when no calendars are available.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No calendars available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a calendar to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group calendars by category
    final groupedCalendars = <String, List<Calendar>>{};
    for (final calendar in widget.calendars) {
      final category = calendar.preferences.category ?? 'Other';
      groupedCalendars.putIfAbsent(category, () => []).add(calendar);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Select Calendars'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedCalendars),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
      body: widget.calendars.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (_selectedCalendars.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Selected (${_selectedCalendars.length})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildSelectedChips(),
                  const Divider(),
                ],
                Expanded(
                  child: ListView(
                    children: groupedCalendars.entries
                        .map((entry) =>
                            _buildCategorySection(entry.key, entry.value))
                        .toList(),
                  ),
                ),
              ],
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
