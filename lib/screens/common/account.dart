import 'package:flutter/material.dart';

import '../../widgets/shared/customAppbar.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);
  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
            child: Text(
              "Account Settings",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Connected accounts & calendars"),
                Row(
                  children: [
                    Text("Email"),
                    Text("Calendards"),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("User Settings"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("First Name"),
                        Text("Last Name"),
                      ],
                    ),
                    Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Email"),
                        Text("Password"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
