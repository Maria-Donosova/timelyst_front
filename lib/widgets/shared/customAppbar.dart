import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../apis/googleIntegration/googleSignInOut.dart';
import '../../services/authService.dart';
import '../../screens/common/connectCalendars.dart';
import '../../screens/common/account.dart';
import '../../screens/common/signUp.dart';
import '../../screens/common/logIn.dart';
import '../../providers/authProvider.dart';

enum _timelystMenu { about, contact_us }

enum _profileView { profile, settings, logout }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return Text('Tame the Time');
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
    final authService = AuthService();
    final googleSignInService = GoogleSignInOutService();

    return [
      if (authProvider.isLoggedIn) ...[
        PopupMenuButton(
          tooltip: 'Account',
          icon: Icon(Icons.menu_outlined),
          elevation: 8,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<_profileView>>[
            PopupMenuItem<_profileView>(
              value: _profileView.profile,
              child: Text('Account Settings'),
              onTap: () async {
                final userId = await authService.getUserId();
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountSettings(
                        authService: authService,
                        userId: userId,
                      ),
                    ),
                  );
                }
              },
            ),
            PopupMenuItem<_profileView>(
              value: _profileView.settings,
              child: Text('Connect Calendars'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectCal()),
                );
              },
            ),
            PopupMenuItem<_profileView>(
              value: _profileView.logout,
              child: Text('Logout'),
              onTap: () async {
                try {
                  // Await all async operations sequentially
                  await googleSignInService.googleSignOut();
                  await authProvider.logout();

                  // Navigate AFTER operations complete
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LogInScreen()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                }
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
        ),
      ]
    ];
  }
}
