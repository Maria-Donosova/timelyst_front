import 'package:flutter/material.dart';
import '../../services/authService.dart';
import '../../widgets/shared/customAppbar.dart';
import '../../screens/common/agenda.dart';
import '../../models/calendars.dart';
import '../../data/calendars.dart';

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

  Future<void> _fetchUserCalendars() async {
    try {
      final token = await widget.authService.getAuthToken();
      if (token == null) throw Exception('No authentication token available');

      final paginatedCalendars = await CalendarsService.fetchUserCalendars(
        userId: widget.userId,
        authToken: token,
      );

      setState(() {
        _calendars = paginatedCalendars.calendars;
        groupedCalendars = _groupCalendarsBySource(_calendars);
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
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
      grouped.putIfAbsent(cal.source, () => []).add(cal);
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
        color: Theme.of(context).colorScheme.surfaceVariant,
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
          color: Theme.of(context).dividerColor.withOpacity(0.1),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
            child: Text(
              "Connected Accounts",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : groupedCalendars.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:timelyst_flutter/widgets/shared/categories.dart';

// import '../../services/authService.dart';

// import '../../widgets/shared/customAppbar.dart';
// import '../../screens/common/agenda.dart';
// import '../../models/calendars.dart';
// import '../../data/calendars.dart';

// class AccountSettings extends StatefulWidget {
//   final AuthService authService;
//   final userId;

//   const AccountSettings({
//     Key? key,
//     required this.authService,
//     required this.userId,
//   }) : super(key: key);

//   static const routeName = '/accountSettings';

//   @override
//   State<AccountSettings> createState() => _AccountSettingsState();
// }

// class _AccountSettingsState extends State<AccountSettings> {
//   late List<Calendar> _calendars;
//   Map<String, List<Calendar>> groupedCalendars = {};
//   late String _userEmail = '';
//   // String _email = 'test@test.com';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserCalendars();
//   }

//   Future<void> _fetchUserCalendars() async {
//     final token = await widget.authService.getAuthToken();
//     //final userId = widget.userId;

//     try {
//       final calendars =
//           await CalendarsService.fetchUserCalendars(widget.userId, token!);
//       // Assuming each Calendar has an 'email' property. Adjust if needed.
//       final email = "mariiadonosova@gmail.com"; // Fetch user email
//       setState(() {
//         _calendars = calendars;
//         _userEmail = email;
//         groupedCalendars = _groupCalendarsByAccount(calendars);
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   Map<String, List<Calendar>> _groupCalendarsByAccount(
//       List<Calendar> calendars) {
//     Map<String, List<Calendar>> grouped = {};
//     for (var cal in calendars) {
//       final email =
//           "mariiadonosova@gmail.com"; // Ensure Calendar has 'email' field
//       grouped.putIfAbsent(email, () => []).add(cal);
//     }
//     return grouped;
//   }

//   Widget _buildSectionHeader(String title) {
//     return Container(
//       color: Theme.of(context).colorScheme.secondary,
//       padding: const EdgeInsets.all(8),
//       margin: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Theme.of(context).colorScheme.onSecondary,
//           fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarTile(Calendar calendar) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: catColor(calendar.preferences.category!),
//         radius: 8,
//       ),
//       title: Text(
//         calendar.metadata.title,
//         style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
//       ),
//     );
//   }

//   void _navigateToAgenda() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Agenda(
//             //calendars: _calendars,
//             //email: _email,
//             ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext contex) {
//     final appBar = CustomAppBar();
//     final mediaQuery = MediaQuery.of(context);

//     if (_isLoading) {
//       return Scaffold(
//         appBar: CustomAppBar(),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: appBar,
//       body: groupedCalendars.isEmpty
//           ? Center(child: Text("No accounts found"))
//           : SafeArea(
//               child: Container(
//                 width: mediaQuery.size.width * 0.99,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 10.0, right: 10.0, top: 50.0, bottom: 40),
//                         child: Text(
//                           "Connected Accounts",
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                       ),
//                       ...groupedCalendars.entries.map((entry) {
//                         final email = entry.key;
//                         final cals = entry.value;
//                         return SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Wrap(
//                               children: [
//                                 Container(
//                                   width: mediaQuery.size.width * 0.25,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 16.0),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 8.0),
//                                           child: Text(
//                                             email,
//                                             style: TextStyle(
//                                               fontSize: Theme.of(context)
//                                                   .textTheme
//                                                   .titleMedium
//                                                   ?.fontSize,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       _buildSectionHeader(
//                                           'Associated Calendars'),
//                                       Column(
//                                         children: cals
//                                             .map((cal) =>
//                                                 _buildCalendarTile(cal))
//                                             .toList(),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ));
//                       }).toList(),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 Theme.of(context).colorScheme.secondary,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           onPressed: _navigateToAgenda,
//                           child: Text('Save',
//                               style: TextStyle(
//                                 color:
//                                     Theme.of(context).colorScheme.onSecondary,
//                               )),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
