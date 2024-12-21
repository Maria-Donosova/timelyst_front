import 'package:flutter/material.dart';

import './googleAuthService.dart';
import './googleCalendarService.dart';
import '../service/connected_accounts.dart';

class GoogleOrchestrator {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final GoogleCalendarService _googleCalendarService = GoogleCalendarService();

  // Orchestrate the Google Sign-In and Calendar Fetching Process
  Future<void> signInAndFetchCalendars(
    BuildContext context,
    ConnectedAccounts connectedAccounts,
  ) async {
    try {
      // Step 1: Authenticate the user
      final authResult =
          await _googleAuthService.requestServerAuthenticatioinCode();

      // if (authResult['email'] != null) {
      //   final email = authResult['email'];
      //   final userId =
      //       'USER_ID_FROM_AUTH_RESULT'; // Replace with actual user ID

      //   // Step 2: Fetch Google Calendars
      //   final calendars =
      //       await _googleCalendarService.fetchGoogleCalendars(userId, email);

      //   // Step 3: Display Calendars to the User (You can navigate to a new screen here)
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => Container(),
      //       // CalendarSelectionScreen(
      //       //   userId: userId,
      //       //   email: email,
      //       //   calendars: calendars,
      //       // ),
      //     ),
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     //SnackBar(content: Text('Sign-in failed: ${authResult['message']}')),
      //   );
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // // Orchestrate the Calendar Saving Process
  // Future<void> saveSelectedCalendars(String userId, List<Calendar> selectedCalendars) async {
  //   try {
  //     await _googleCalendarService.saveSelectedCalendars(
  //         userId, selectedCalendars);
  //     print('Calendars saved successfully!');
  //   } catch (e) {
  //     print('Error saving calendars: $e');
  //   }
  // }
}
