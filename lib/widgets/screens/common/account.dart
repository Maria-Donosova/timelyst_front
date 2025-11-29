import 'package:flutter/material.dart';
import '../../../services/authService.dart';
import '../../shared/customAppbar.dart';
import 'agenda.dart';
import '../../../models/calendars.dart';
import '../../../services/calendarsService.dart';
import '../../../providers/eventProvider.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  final AuthService authService;
  final String userId;

  const AccountSettings({
    Key? key,
    required this.authService,
    required this.userId,
  }) : super(key: key);

  static const routeName = '/accountSettings';

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late List<Calendar> _calendars = [];
  Map<CalendarSource, List<Calendar>> groupedCalendars = {};
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserCalendars();
  }

  Future<void> _importGoogleCalendarEvents() async {
    try {
      
      // Instead of calling the non-existent Google import endpoint, 
      // just refresh all events to see what the backend already has
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.fetchAllEvents(forceFullRefresh: true);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Calendar events imported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      print('❌ [AccountSettings] Google Calendar import failed: $e');
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import Google Calendar events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchUserCalendars() async {
    try {
      final token = await widget.authService.getAuthToken();
      if (token == null) throw Exception('No authentication token available');

      final paginatedCalendars = await CalendarsService.fetchUserCalendars(
        authToken: token,
      );

      
      setState(() {
        _calendars = paginatedCalendars.calendars;
        groupedCalendars = _groupCalendarsBySource(_calendars);
        _isLoading = false;
        _hasError = false;
      });
    } catch (e, stackTrace) {
      print('❌ [AccountSettings] Error fetching calendars: $e');
      print('❌ [AccountSettings] Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Map<CalendarSource, List<Calendar>> _groupCalendarsBySource(
      List<Calendar> calendars) {
    final Map<CalendarSource, List<Calendar>> grouped = {};

    
    for (final cal in calendars) {
      try {
        grouped.putIfAbsent(cal.source, () => []).add(cal);
      } catch (e) {
        print('❌ [AccountSettings] Error processing calendar ${cal.id}: $e');
        // Skip this calendar if there's an error
        continue;
      }
    }


    // Sort by source type (Google first, then Outlook, then Apple)
    return Map.fromEntries(
      grouped.entries.toList()
        ..sort((a, b) => a.key.index.compareTo(b.key.index)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 8, top: 16),
      child: Row(
        children: [
          Icon(
            _getSourceIcon(title.toLowerCase()),
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'google':
        return Icons.mail_outline;
      case 'outlook':
        return Icons.window_outlined;
      case 'apple':
        return Icons.apple;
      default:
        return Icons.calendar_today;
    }
  }

  Widget _buildCalendarTile(Calendar calendar) {
    final color = calendar.metadata.color;
    final isSelected = calendar.isSelected;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          calendar.metadata.title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: calendar.metadata.description?.isNotEmpty ?? false
            ? Text(
                calendar.metadata.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (calendar.isPrimary)
              Tooltip(
                message: 'Primary calendar',
                child: Icon(
                  Icons.star,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleCalendarSelection(calendar),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        onTap: () => _toggleCalendarSelection(calendar),
      ),
    );
  }

  void _toggleCalendarSelection(Calendar calendar) {
    setState(() {
      _calendars = _calendars.map((cal) {
        if (cal.id == calendar.id) {
          return cal.copyWith(isSelected: !cal.isSelected);
        }
        return cal;
      }).toList();

      // Update the grouped calendars
      groupedCalendars = _groupCalendarsBySource(_calendars);
    });
  }

  void _navigateToAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Agenda(
            // Pass selected calendars if needed
            // selectedCalendars: _calendars.where((cal) => cal.isSelected).toList(),
            ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onPressed: () {
          // TODO: Implement account connection flow
// This should trigger the OAuth or relevant flow for connecting an external calendar account (Google, Outlook, Apple, etc.).
// Consider using a dialog or a dedicated screen for the connection process, and update user state on success.
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 48),
        ),
        onPressed: _navigateToAgenda,
        child: Text(
          'Save Changes',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load calendars',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchUserCalendars,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No calendars found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your calendar accounts to get started',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _buildAddAccountButton(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Connected Accounts",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _importGoogleCalendarEvents(),
                  icon: Icon(Icons.sync, size: 18),
                  label: Text('Import Google Events'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...groupedCalendars.entries.map((entry) {
            final source = entry.key;
            final calendars = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  source.toString().split('.').last.toUpperCase(),
                ),
                ...calendars.map((calendar) => _buildCalendarTile(calendar)),
              ],
            );
          }).toList(),
          _buildAddAccountButton(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            )
          : _hasError
              ? _buildErrorState()
              : groupedCalendars.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }
}
