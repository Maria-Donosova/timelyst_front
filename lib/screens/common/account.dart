import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';

import '../../services/authService.dart';

import '../../widgets/shared/customAppbar.dart';
import '../../screens/common/agenda.dart';
import '../../models/calendars.dart';
import '../../data/calendars.dart';

class AccountSettings extends StatefulWidget {
  final AuthService authService;
  final userId;

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
  late List<Calendar> _calendars;
  // String _email = 'test@test.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    //   _calendars = List.generate(
    // widget.calendars.length,
    // (index) => Calendar(),
    _fetchUserCalendars();
  }

  Future<List<Calendar>> _fetchUserCalendars() async {
    final token = await widget.authService.getAuthToken();
    final userId = widget.userId;
    print('Token: $token');
    print('UserId: $userId');

    try {
      // Fetch calendars from the service
      final calendars =
          await CalendarsService.fetchUserCalendars(widget.userId, token!);

      // Update the state
      setState(() {
        _calendars = calendars;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching calendars: $e');
      setState(() {
        _isLoading = false;
      });
    }
    return _calendars;
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        ),
      ),
    );
  }

  Widget _buildCalendarSection(int index) {
    print("Entering build Calendar Section in within the account settings");
    final calendar = _calendars[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("test@fng.com")),
          _buildSectionHeader("Associated Calendars"),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8.0),
          //   child: Text(
          //     calendar.title,
          //     style: TextStyle(
          //       fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          //     ),
          //   ),
          // ),
          _buildCalendarTile(index),
        ],
      ),
    );
  }

  Widget _buildCalendarTile(int index) {
    final calendar = _calendars[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: CircleAvatar(
              //backgroundColor: Colors.cyan,
              backgroundColor: catColor(calendar.category!),
              radius: 3.5,
            ),
          ),
          Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Text(
                calendar.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
              // Column(
              //   children: _calendars.map((calendar) {
              //     return Text(
              //       calendar.title,
              //       style: TextStyle(
              //         color: Theme.of(context).colorScheme.onBackground,
              //       ),
              //     );
              //   }).toList(),
              // ),
              ),
        ],
      ),
    );
  }

  void _navigateToAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Agenda(
            //calendars: _calendars,
            //email: _email,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext contex) {
    print("Building AccountSettings with:");
    final appBar = CustomAppBar();
    final mediaQuery = MediaQuery.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: _calendars.isEmpty
          ? Center(child: Text("No accounts found"))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 50.0, bottom: 20),
                        child: Text(
                          "Connected Accounts",
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          children: [
                            Row(
                              children: List.generate(
                                _calendars.length,
                                (index) => Container(
                                  width: mediaQuery.size.width * 0.25,
                                  child: _buildCalendarSection(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.stretch,
                      //   children: [
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 8),
                      //       margin: const EdgeInsets.only(bottom: 10),
                      //       child: Column(
                      //         children: [
                      //           Container(
                      //             child: _buildCalendarSection(index),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.stretch,
                      //   children: [
                      //     _buildSectionHeader("User Settings"),
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 8),
                      //       margin: const EdgeInsets.only(bottom: 10),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         children: [
                      //           Container(
                      //             child: Column(
                      //               children: [
                      //                 Text("First Name"),
                      //                 Text("Last Name"),
                      //               ],
                      //             ),
                      //           ),
                      //           Container(
                      //             child: Column(
                      //               children: [
                      //                 Text("Email"),
                      //                 Text("Password"),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _navigateToAgenda,
                          child: Text('Save',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              )),
                        ),
                      ),
                    ]),
              ),
            ),
    );
  }
}
