import 'package:flutter/material.dart';

import '../../models/calendars.dart';
import 'googleSignInOut.dart';
import 'googleAuthService.dart';
import 'googleCalendarService.dart';
import '../connected_accounts.dart';

class GoogleOrchestrator {
  //final GoogleAuthService _googleAuthService = GoogleAuthService();
  final GoogleCalendarService _googleCalendarService = GoogleCalendarService();
  final GoogleSignInOutService _googleSingInOutService =
      GoogleSignInOutService();

  // Orchestrate the Google Sign-In and Calendar Fetching Process
  Future<Map<String, dynamic>> signInAndFetchCalendars(
    BuildContext context,
    ConnectedAccounts connectedAccounts,
  ) async {
    print("Entering signInAndFetchCalendars");
    try {
      // Step 1: Sign in with Google
      final signInResult = await _googleSingInOutService.googleSignIn(
        context,
        connectedAccounts,
      );
      print("Sign-in result: $signInResult");

      // Step 2: Fetch Google Calendars
      final userId = signInResult['userId'];
      final email = signInResult['email'];
      print("userID: $userId");
      print("email: $email");

      final calendars =
          await _googleCalendarService.fetchGoogleCalendars(userId, email);
      print("Calendars: $calendars");

      // Step 3: Display Calendars to the User (You can navigate to a new screen here)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Container(),
          // CalendarSelectionScreen(
          //   userId: userId,
          //   email: email,
          //   calendars: calendars,
          // ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return {'error': e.toString()};
    }
    return {'status': 'success'};
  }

  // Orchestrate the Calendar Saving Process
  Future<void> saveSelectedCalendars(
      String userId, List<Calendar> selectedCalendars) async {
    try {
      await _googleCalendarService.saveSelectedCalendars(
          userId, selectedCalendars);
      print('Calendars saved successfully!');
    } catch (e) {
      print('Error saving calendars: $e');
    }
  }
}
