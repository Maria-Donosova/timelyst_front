
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import 'package:timelyst_flutter/widgets/screens/common/logIn.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      return AgendaView();
    } else {
      return FutureBuilder(
        future: authProvider.tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (authProvider.isLoggedIn) {
              return AgendaView();
            } else {
              return LogInScreen();
            }
          }
        },
      );
    }
  }
}
