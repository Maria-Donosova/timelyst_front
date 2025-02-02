import 'package:flutter/material.dart';

import '../../widgets/shared/customAppbar.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);
  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account User Name"),
              Text("Account User Last Name"),
              Text("Email"),
              Text("Password"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Connected accounts"),
              Text("Email"),
              Text("Calendards"),
            ],
          )
        ]),
      ),
    );
  }
}
