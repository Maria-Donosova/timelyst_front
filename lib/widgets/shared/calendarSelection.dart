import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendarProvider.dart';
import '../../models/calendars.dart';
import '../../services/authService.dart';

/// A screen that allows the user to select one or more calendars from a list,
/// grouped by category for better organization.
class CalendarSelectionScreen extends StatefulWidget {
  final List<Calendar>? calendars;
  final List<Calendar> initiallySelectedCalendars;

  const CalendarSelectionScreen({
    this.calendars,
    this.initiallySelectedCalendars = const [],
  });

  @override
  State<CalendarSelectionScreen> createState() =>
      _CalendarSelectionScreenState();
}

class _CalendarSelectionScreenState extends State<CalendarSelectionScreen> {
  late final List<Calendar> _selectedCalendars;
  late CalendarProvider _calendarProvider;
  late AuthService _authService;
  bool _isLoading = false;
  String _errorMessage = '';
  List<Calendar> _calendars = [];

  @override
  void initState() {
    super.initState();
    // Initialize the list of selected calendars with the initial values.
    _selectedCalendars = List.from(widget.initiallySelectedCalendars);
    _authService = Provider.of<AuthService>(context, listen: false);
    _calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    // Use provided calendars or fetch from provider
    if (widget.calendars != null && widget.calendars!.isNotEmpty) {
      _calendars = widget.calendars!;
    } else {
      _loadCalendars();
    }
  }

  /// Fetches the list of calendars from the CalendarProvider.
  Future<void> _loadCalendars() async {
    if (_calendarProvider.calendars.isNotEmpty) {
      setState(() {
        _calendars = _calendarProvider.calendars;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not available. Please log in.';
          _isLoading = false;
        });
        return;
      }

      // Initialize the calendar provider with userId if not already done
      await _calendarProvider.initialize(userId);

      setState(() {
        _calendars = _calendarProvider.calendars;

        // Initialize selection with any new calendars that match initially selected IDs
        if (widget.initiallySelectedCalendars.isNotEmpty) {
          final initialIds = widget.initiallySelectedCalendars.map((c) => c.id).toSet();
          _selectedCalendars.clear();
          _selectedCalendars.addAll(
            _calendarProvider.calendars.where((c) => initialIds.contains(c.id))
          );
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load calendars: ${e.toString()}';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error message
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCalendars,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (_calendars.isEmpty) {
      return _buildEmptyState();
    }

    // Group calendars by category
    final groupedCalendars = <String, List<Calendar>>{};
    for (final calendar in _calendars) {
      final category = calendar.preferences.category ?? 'Other';
      groupedCalendars.putIfAbsent(category, () => []).add(calendar);
    }

    // Show calendars
    return Column(
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
                .map((entry) => _buildCategorySection(entry.key, entry.value))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Shows a dialog to select calendars.
///
/// Displays [CalendarSelectionScreen] which will automatically fetch
/// calendars from [CalendarProvider] if not already loaded.
/// Returns a list of selected [Calendar] objects, or `null` if the
/// dialog is dismissed.
Future<List<Calendar>?> showCalendarSelectionDialog(
  BuildContext context, {
  List<Calendar> selectedCalendars = const [],
}) async {
  return await Navigator.of(context).push<List<Calendar>>(
    MaterialPageRoute(
      builder: (context) => CalendarSelectionScreen(
        initiallySelectedCalendars: selectedCalendars,
      ),
    ),
  );
}
