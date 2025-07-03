import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../../models/calendars.dart';

class CalendarSelectionWidget extends StatefulWidget {
  final List<Calendar>? initiallySelectedCalendars;

  const CalendarSelectionWidget({
    Key? key,
    this.initiallySelectedCalendars,
  }) : super(key: key);

  @override
  _CalendarSelectionWidgetState createState() =>
      _CalendarSelectionWidgetState();
}

class _CalendarSelectionWidgetState extends State<CalendarSelectionWidget> {
  late List<Calendar> _selectedCalendars;
  late CalendarProvider _calendarProvider;
  late AuthService _authService;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _selectedCalendars = widget.initiallySelectedCalendars ?? [];
    _authService = Provider.of<AuthService>(context, listen: false);
    _calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    if (_calendarProvider.calendars.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        setState(() => _errorMessage = 'User ID not available. Please log in.');
        return;
      }

      await _calendarProvider.loadInitialCalendars();

      // Initialize selection with any new calendars that match initially selected IDs
      if (widget.initiallySelectedCalendars != null) {
        final initialIds =
            widget.initiallySelectedCalendars!.map((c) => c.id).toSet();
        _selectedCalendars = _calendarProvider.calendars
            .where((c) => initialIds.contains(c.id))
            .toList();
      }
    } catch (e) {
      setState(
          () => _errorMessage = 'Failed to load calendars: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleCalendar(Calendar calendar, bool selected) {
    setState(() {
      if (selected) {
        _selectedCalendars.add(calendar);
      } else {
        _selectedCalendars.removeWhere((c) => c.id == calendar.id);
      }
      _hasChanges = true;
    });
  }

  Widget _buildCategorySection(String category, List<Calendar> calendars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            category.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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

  Widget _buildCalendarTile(Calendar calendar) {
    final isSelected = _selectedCalendars.any((c) => c.id == calendar.id);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _toggleCalendar(calendar, !isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Color(calendar.preferences.userColor as int),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Expanded(
              child: Text(
                calendar.metadata.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleCalendar(calendar, value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onDeleted: () => _toggleCalendar(calendar, false),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No calendars available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a calendar to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    final groupedCalendars = <String, List<Calendar>>{};
    for (final calendar in _calendarProvider.calendars) {
      final category = calendar.preferences.category ?? 'Other';
      groupedCalendars.putIfAbsent(category, () => []).add(calendar);
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Select Calendars',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedCalendars.isNotEmpty) ...[
              Text(
                'Selected (${_selectedCalendars.length})',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              _buildSelectedChips(),
              const SizedBox(height: 16),
            ],
            if (groupedCalendars.isNotEmpty)
              ...groupedCalendars.entries
                  .map((entry) => _buildCategorySection(entry.key, entry.value))
                  .toList(),
            if (groupedCalendars.isEmpty) _buildEmptyState(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _hasChanges || widget.initiallySelectedCalendars == null
              ? () => Navigator.pop(context, _selectedCalendars)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Apply Selection'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
    );
  }
}

Future<List<Calendar>?> showCalendarSelectionDialog(
  BuildContext context, {
  List<Calendar>? initiallySelectedCalendars,
}) async {
  return await showDialog<List<Calendar>>(
    context: context,
    builder: (context) => CalendarSelectionWidget(
      initiallySelectedCalendars: initiallySelectedCalendars,
    ),
  );
}
