import 'package:flutter/material.dart';

import '../../widgets/shared/custom_appbar.dart';

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
          Text("Account User Name"),
          Text("Account User Last Name"),
          Text("Email"),
          Text("Password"),
          Text("Calendards Connected"),
        ]),
      ),
    );
  }
}
