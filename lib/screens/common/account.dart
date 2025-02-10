import 'package:flutter/material.dart';
import 'package:timelyst_flutter/screens/common/agenda.dart';
import '../../models/calendars.dart';

import '../../widgets/shared/customAppbar.dart';

class AccountSettings extends StatefulWidget {
  final List<Calendar> calendars;
  final String email;

  const AccountSettings({
    Key? key,
    required this.calendars,
    required this.email,
  }) : super(key: key);

  static const routeName = '/accountSettings';

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  //late List<ImportSettings> _importSettingsList;
  // late List<String> _selectedCategories;

  @override
  void initState() {
    assert(widget.calendars != null, "Calendars list must not be null");
    assert(widget.email != null, "Email must not be null");
    super.initState();
  }

  void _navigateToAgenda() {
    final _selectedCalendars = widget.calendars.asMap().entries.map((entry) {
      final index = entry.key;
      return Calendar(
        user: entry.value.user,
        title: entry.value.title,
        // Add other necessary fields from import settings
        // ...
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Agenda(
            // calendars: selectedCalendars,
            // userId: widget.userId,
            // email: widget.email,
            ),
      ),
    );
  }

  Widget _buildCalendarSection(int index) {
    print("Entering build Calendar Section in within the account settings");
    final calendar = widget.calendars[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Calendar title header
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              calendar.title,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext contex) {
    print("Building AccountSettings with:");
    print("- Calendars count: ${widget.calendars.length}");
    print("- Email: ${widget.email}");

    final appBar = CustomAppBar();

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

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 50.0, bottom: 20),
            child: Text(
              "Account Settings",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader("Connected Accounts & Calendars"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(widget.email)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            backgroundColor: Colors.cyan,
                            //backgroundColor: catColor(customAppointment.catTitle),
                            radius: 3.5,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: widget.calendars.map((calendar) {
                              return Text(
                                calendar.title,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader("User Settings"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text("First Name"),
                          Text("Last Name"),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text("Email"),
                          Text("Password"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _navigateToAgenda,
              child: Text('Save',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  )),
            ),
          ),
        ]),
      ),
    );
  }
}
