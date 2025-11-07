/// A widget that allows users to select from a list of available calendars.
///
/// This widget is presented as a dialog and is used to manage which calendars
/// are displayed throughout the application. It fetches calendars from a
/// [CalendarProvider] and allows for multiple selections.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../../models/calendars.dart';

/// A stateful widget that provides a UI for selecting calendars.
///
/// It takes an optional list of [initiallySelectedCalendars] to pre-select
/// calendars when the widget is first displayed.
class CalendarSelectionWidget extends StatefulWidget {
  final List<Calendar>? selectedCalendars;

  const CalendarSelectionWidget({
    super.key,
    this.selectedCalendars,
  });

  @override
  State<CalendarSelectionWidget> createState() =>
      _CalendarSelectionWidgetState();
}

/// The state for the [CalendarSelectionWidget].
///
/// This class manages the state of the calendar selection, including the list
/// of selected calendars, loading state, and any potential error messages.
class _CalendarSelectionWidgetState extends State<CalendarSelectionWidget> {
  /// The list of calendars that are currently selected by the user.
  late List<Calendar> _selectedCalendars;

  /// The provider responsible for fetching and managing calendar data.
  late CalendarProvider _calendarProvider;

  /// The service for handling user authentication and retrieving user information.
  late AuthService _authService;

  /// A flag to indicate whether the calendar data is currently being loaded.
  bool _isLoading = false;

  /// A message to display if an error occurs while loading calendars.
  String _errorMessage = '';

  /// Initializes the state of the widget.
  ///
  /// This method is called when the widget is first created. It sets up the
  /// initial list of selected calendars, initializes the required providers and
  /// services, and triggers the loading of calendar data.
  @override
  void initState() {
    super.initState();
    _selectedCalendars = widget.selectedCalendars?.toList() ?? [];
    _authService = Provider.of<AuthService>(context, listen: false);
    _calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    _loadCalendars();
  }

  /// Fetches the list of calendars from the [CalendarProvider].
  ///
  /// Sets the loading state, retrieves the user ID, and then loads the calendars.
  /// If calendars are already loaded, it does nothing. It also handles any
  /// errors that might occur during the process.
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
      if (widget.selectedCalendars != null) {
        final initialIds = widget.selectedCalendars!.map((c) => c.id).toSet();
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

  /// Adds or removes a calendar from the list of selected calendars.
  ///
  /// This method is called when a user taps on a calendar's checkbox.
  /// It updates the [_selectedCalendars] list.
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
  ///
  /// Each section consists of a category title and a list of calendars belonging
  /// to that category, each with a checkbox for selection.
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

  /// Builds a single calendar list tile with selection controls.
  ///
  /// This tile displays the calendar's title, color, and a checkbox to indicate
  /// its selection status.

  /// Builds a wrap of chips for the currently selected calendars.
  ///
  /// Each chip displays the title of a selected calendar and includes a delete
  /// icon to allow for quick deselection.
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

  /// Builds the UI to be displayed when no calendars are available.
  ///
  /// This provides a user-friendly message indicating that no calendars were found.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
    );
  }

  /// Builds the main UI of the calendar selection dialog.
  ///
  /// It handles displaying a loading indicator, an error message, or the list
  /// of calendars grouped by category. It also includes action buttons for
  /// canceling or applying the selection.
  @override
  Widget build(BuildContext context) {
    print("Entering calendar selection build");
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    final groupedCalendars = <String, List<Calendar>>{};
    for (final calendar in _calendarProvider.calendars) {
      final category = calendar.preferences.category ?? 'Other';
      groupedCalendars.putIfAbsent(category, () => []).add(calendar);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
        const SizedBox(height: 16),
        SingleChildScrollView(
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
                    .map((entry) =>
                        _buildCategorySection(entry.key, entry.value))
                    .toList(),
              if (groupedCalendars.isEmpty) _buildEmptyState(),
            ],
          ),
        ),
      ],
    );
  }
}

/// A utility function to show the [CalendarSelectionWidget] as a dialog.
///
/// This function simplifies the process of displaying the calendar selection
/// dialog and returns the list of selected calendars when the dialog is closed.
Future<List<Calendar>?> showCalendarSelectionDialog(
  BuildContext context, {
  List<Calendar>? selectedCalendars,
}) async {
  return await showDialog<List<Calendar>>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SizedBox(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        child: CalendarSelectionWidget(
          selectedCalendars: selectedCalendars,
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
          onPressed: () => Navigator.pop(context, _selectedCalendars),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Save'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
    ),
  );
}

class _selectedCalendars {}
