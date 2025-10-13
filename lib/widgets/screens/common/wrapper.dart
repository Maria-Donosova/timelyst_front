import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import 'package:timelyst_flutter/widgets/screens/common/logIn.dart';
import 'package:timelyst_flutter/widgets/screens/common/connectCalendars.dart';
import 'dart:html' as html;

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if this is a Microsoft OAuth callback
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters.containsKey('code')) {
      // Clean up URL after getting the auth code to prevent issues
      final authCode = uri.queryParameters['code'];
      // Remove query params from URL immediately to clean up browser history
      html.window.history.replaceState(null, '', '/');
      // Return to ConnectCal screen which will handle the callback
      return ConnectCal(microsoftAuthCode: authCode);
    }

    if (authProvider.isLoggedIn) {
      return Agenda();
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
              return Agenda();
            } else {
              return LogInScreen();
            }
          }
        },
      );
    }
  }
}
