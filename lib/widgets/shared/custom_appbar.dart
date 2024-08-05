import 'package:flutter/material.dart';

//import '../shared/search.dart';

enum _timelystMenu { about, contact_us }

enum _profileView { profile, settings, logout }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 3,
      shadowColor: Theme.of(context).shadowColor,
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildTitle() {
    return Text(
      'Tame the Time',
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return PopupMenuButton(
      icon: Image.asset("assets/images/logos/timelyst_logo.png"),
      iconSize: 20,
      elevation: 8,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_timelystMenu>>[
        const PopupMenuItem<_timelystMenu>(
          value: _timelystMenu.about,
          child: Text('About'),
        ),
        const PopupMenuItem<_timelystMenu>(
          value: _timelystMenu.contact_us,
          child: Text('Contact Us'),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    return [
      Row(
        children: [
          // Container(
          //   width: mediaQuery.size.width * 0.1,
          //   child: TextFormField(
          //     autocorrect: true,
          //     decoration: InputDecoration(
          //       border: InputBorder.none,
          //       icon: Icon(
          //         Icons.search_outlined,
          //         color: Colors.grey.shade800,
          //       ),
          //       labelStyle: TextStyle(fontSize: 10),
          //       errorStyle: TextStyle(color: Colors.redAccent),
          //     ),
          //     textInputAction: TextInputAction.next,
          //     onFieldSubmitted: (
          //       FilterByTaskEvent,
          //     ) {},
          //   ),
          // ),
        ],
      ),
      PopupMenuButton(
        icon: Icon(
          Icons.menu_outlined,
          color: Colors.grey[800],
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
    ];
  }
}
