import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/screens/common/sign_up.dart';

import '../../providers/auth_provider.dart';

//import '../shared/search.dart';

enum _timelystMenu { about, contact_us }

enum _profileView { profile, settings, logout }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider to listen to changes
    final authProvider = Provider.of<AuthProvider>(context);

    print('Building CustomAppBar');

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
            const PopupMenuItem<_profileView>(
              value: _profileView.profile,
              child: Text('Account'),
            ),
            const PopupMenuItem<_profileView>(
              value: _profileView.settings,
              child: Text('Settings'),
            ),
            const PopupMenuItem<_profileView>(
              value: _profileView.logout,
              child: Text('Logout'),
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
