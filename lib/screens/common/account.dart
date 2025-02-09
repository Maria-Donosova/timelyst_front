import 'package:flutter/material.dart';
import '../../models/calendars.dart';

import '../../widgets/shared/customAppbar.dart';

class Account extends StatelessWidget {
  final String email;
  final String calendars;

  const Account({
    Key? key,
    required this.email,
    required this.calendars,
  }) : super(key: key);
  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map;
    final String email = routeArgs['email'];
    final List<Calendar> calendars = routeArgs['calendars'];

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
                            child: Text(email)),
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
                          child: Text(
                            calendars.isNotEmpty
                                ? calendars.map((c) => c.title).join(', ')
                                : 'No calendars connected',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
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
        ]),
      ),
    );
  }
}
