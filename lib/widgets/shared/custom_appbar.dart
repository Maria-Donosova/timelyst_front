import 'package:flutter/material.dart';

import '../shared/search.dart';

enum _timelystMenu { about, contact_us }

enum _profileView { profile, settings, logout }

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key? key,
  }) : super(
          key: key,
          backgroundColor: Colors.white,
          leading: PopupMenuButton(
            icon: Image.asset(
              "assets/images/logos/timelyst_logo.png",
            ),
            iconSize: 20,
            elevation: 8,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_timelystMenu>>[
              const PopupMenuItem<_timelystMenu>(
                value: _timelystMenu.about,
                child: Text('About'),
              ),
              const PopupMenuItem<_timelystMenu>(
                value: _timelystMenu.contact_us,
                child: Text('Contact Us'),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search_outlined,
                color: Colors.grey[800],
              ),
              onPressed: () => SearchW(),
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.menu_outlined,
                color: Colors.grey[800],
              ),
              elevation: 8,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_profileView>>[
                const PopupMenuItem<_profileView>(
                  value: _profileView.profile,
                  child: Text('Profile'),
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
          ],
        );
}
