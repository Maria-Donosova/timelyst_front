import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/screens/common/calendarSettings.dart';
import '../../screens/common/connectCalendars.dart';

import '../../screens/common/signUp.dart';
import '../../screens/common/logIn.dart';
import '../../providers/authProvider.dart';
//import '../../screens/common/account.dart';
//import '../shared/search.dart';

enum _timelystMenu { about, contact_us }

enum _profileView { profile, settings, logout }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider to listen to changes
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      title: _buildTitle(),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 3,
      shadowColor: Theme.of(context).shadowColor,
      leading: _buildLeading(context),
      actions: _buildActions(context, authProvider),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildTitle() {
    return Text(
      'Tame the Time',
    );
  }

  Widget _buildLeading(BuildContext context) {
    return PopupMenuButton(
      tooltip: 'About',
      icon: Image.asset("assets/images/logos/timelyst_logo.png"),
      iconSize: 20,
      elevation: 8,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_timelystMenu>>[
        const PopupMenuItem<_timelystMenu>(
          value: _timelystMenu.about,
          child: Text('About Us'),
        ),
        const PopupMenuItem<_timelystMenu>(
          value: _timelystMenu.contact_us,
          child: Text('Contact'),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, AuthProvider authProvider) {
    // Use the authProvider to determine the actions
    return [
      if (authProvider.isLoggedIn) ...[
        PopupMenuButton(
          tooltip: 'Account',
          icon: Icon(
            Icons.menu_outlined,
          ),
          elevation: 8,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_profileView>>[
            PopupMenuItem<_profileView>(
              value: _profileView.profile,
              child: Text('Account'),
              onTap: () {
                print('Agenda Settings');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => CalendarSettings(
                            calendars: [], // Provide the appropriate list of calendars
                            userId:
                                "authProvider.userId", // Provide the userId from authProvider
                            email:
                                "authProvider.email", // Provide the email from authProvider
                          )),
                );
              },
            ),
            PopupMenuItem<_profileView>(
              value: _profileView.settings,
              child: Text('Settings'),
              onTap: () {
                print('Settings');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ConnectCal()));
              },
            ),
            PopupMenuItem<_profileView>(
              value: _profileView.logout,
              child: Text('Logout'),
              onTap: () {
                print('Logging out');
                authProvider.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                );
              },
            ),
          ],
        ),
      ] else ...[
        TextButton(
          child: Text('Sign Up',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              )),
          onPressed: () {
            //_saveForm,
            print('sign up button pressed');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
            // }
          },
        ),
      ]
    ];
  }
}
