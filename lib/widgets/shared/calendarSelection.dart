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
  final AuthService? authService;
  final CalendarProvider? calendarProvider;

  const CalendarSelectionScreen({
    this.calendars,
    this.initiallySelectedCalendars = const [],
    this.authService,
    this.calendarProvider,
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
    print('[CalendarSelection] initState - Starting initialization');
    // Initialize the list of selected calendars with the initial values.
    _selectedCalendars = List.from(widget.initiallySelectedCalendars);
    print('[CalendarSelection] Initially selected: ${_selectedCalendars.length} calendars');

    // Try to get services from widget parameters first, then from context
    bool hasAuthService = false;
    bool hasCalendarProvider = false;

    if (widget.authService != null) {
      _authService = widget.authService!;
      hasAuthService = true;
      print('[CalendarSelection] Using AuthService from widget parameter');
    }

    if (widget.calendarProvider != null) {
      _calendarProvider = widget.calendarProvider!;
      hasCalendarProvider = true;
      print('[CalendarSelection] Using CalendarProvider from widget parameter');
    }

    // Try to get from context if not provided
    if (!hasAuthService) {
      try {
        _authService = Provider.of<AuthService>(context, listen: false);
        hasAuthService = true;
        print('[CalendarSelection] Got AuthService from context');
      } catch (e) {
        print('[CalendarSelection] Could not get AuthService from context (will try to work without it): $e');
      }
    }

    if (!hasCalendarProvider) {
      try {
        _calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
        hasCalendarProvider = true;
        print('[CalendarSelection] Got CalendarProvider from context');
      } catch (e) {
        print('[CalendarSelection] ERROR: Could not get CalendarProvider: $e');
      }
    }

    // CalendarProvider is absolutely required
    if (!hasCalendarProvider) {
      print('[CalendarSelection] ERROR: CalendarProvider is required but not found');
      setState(() {
        _errorMessage = 'Failed to initialize: Calendar service not available. Please try again.';
      });
      return;
    }

    print('[CalendarSelection] Successfully got CalendarProvider');

    // Use provided calendars or fetch from provider
    if (widget.calendars != null && widget.calendars!.isNotEmpty) {
      print('[CalendarSelection] Using provided calendars: ${widget.calendars!.length}');
      _calendars = widget.calendars!;
    } else if (_calendarProvider.calendars.isNotEmpty) {
      // CalendarProvider already has calendars - use them!
      print('[CalendarSelection] Using existing calendars from CalendarProvider: ${_calendarProvider.calendars.length}');
      _calendars = _calendarProvider.calendars;
    } else {
      // Need to load calendars - check if we have AuthService
      if (!hasAuthService) {
        print('[CalendarSelection] ERROR: Need to load calendars but AuthService not available');
        setState(() {
          _errorMessage = 'Failed to initialize: Authentication service not available. Please ensure you are logged in and try again.';
        });
        return;
      }
      print('[CalendarSelection] No calendars available, will load from provider');
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCalendars();
      });
    }
  }

  /// Fetches the list of calendars from the CalendarProvider.
  Future<void> _loadCalendars() async {
    print('[CalendarSelection] _loadCalendars - Starting');
    print('[CalendarSelection] Provider already has ${_calendarProvider.calendars.length} calendars');

    if (_calendarProvider.calendars.isNotEmpty) {
      print('[CalendarSelection] Using existing calendars from provider');
      setState(() {
        _calendars = _calendarProvider.calendars;
      });
      return;
    }

    print('[CalendarSelection] Setting loading state to true');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('[CalendarSelection] Getting userId from AuthService');
      final userId = await _authService.getUserId();
      print('[CalendarSelection] UserId: $userId');

      if (userId == null) {
        print('[CalendarSelection] ERROR: User ID is null');
        setState(() {
          _errorMessage = 'User ID not available. Please log in.';
          _isLoading = false;
        });
        return;
      }

      print('[CalendarSelection] Initializing calendar provider with userId: $userId');
      // Initialize the calendar provider with userId if not already done
      await _calendarProvider.initialize(userId);

      print('[CalendarSelection] Calendar provider initialized. Calendars count: ${_calendarProvider.calendars.length}');

      if (!mounted) {
        print('[CalendarSelection] Widget no longer mounted, aborting');
        return;
      }

      setState(() {
        _calendars = _calendarProvider.calendars;
        print('[CalendarSelection] Set _calendars to ${_calendars.length} items');

        // Initialize selection with any new calendars that match initially selected IDs
        if (widget.initiallySelectedCalendars.isNotEmpty) {
          final initialIds = widget.initiallySelectedCalendars.map((c) => c.id).toSet();
          _selectedCalendars.clear();
          _selectedCalendars.addAll(
            _calendarProvider.calendars.where((c) => initialIds.contains(c.id))
          );
          print('[CalendarSelection] Updated selected calendars to ${_selectedCalendars.length}');
        }
      });
    } catch (e, stackTrace) {
      print('[CalendarSelection] ERROR: Failed to load calendars: $e');
      print('[CalendarSelection] Stack trace: $stackTrace');
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
        print('[CalendarSelection] Setting loading state to false');
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
    print('[CalendarSelection] _buildBody - isLoading: $_isLoading, hasError: ${_errorMessage.isNotEmpty}, calendars: ${_calendars.length}');

    // Show loading indicator
    if (_isLoading) {
      print('[CalendarSelection] Showing loading indicator');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error message
    if (_errorMessage.isNotEmpty) {
      print('[CalendarSelection] Showing error: $_errorMessage');
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
  print('[CalendarSelection] showCalendarSelectionDialog called with ${selectedCalendars.length} selected calendars');

  // Try to get providers from the current context before navigation
  AuthService? authService;
  CalendarProvider? calendarProvider;

  try {
    authService = Provider.of<AuthService>(context, listen: false);
    print('[CalendarSelection] Got AuthService from context');
  } catch (e) {
    print('[CalendarSelection] WARNING: Could not get AuthService from context: $e');
  }

  try {
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    print('[CalendarSelection] Got CalendarProvider from context');
  } catch (e) {
    print('[CalendarSelection] WARNING: Could not get CalendarProvider from context: $e');
  }

  print('[CalendarSelection] Providers - AuthService: ${authService != null}, CalendarProvider: ${calendarProvider != null}');

  return await Navigator.of(context).push<List<Calendar>>(
    MaterialPageRoute(
      builder: (context) => CalendarSelectionScreen(
        initiallySelectedCalendars: selectedCalendars,
        authService: authService,
        calendarProvider: calendarProvider,
      ),
    ),
  );
}
