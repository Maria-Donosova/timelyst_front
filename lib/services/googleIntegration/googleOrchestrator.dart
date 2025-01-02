import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/shared/calendarSelection.dart';

import '../../models/calendars.dart';
import 'googleSignInOut.dart';
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
      print(
          "Google calendars returned by the backend: ${calendars.map((calendar) => calendar.toString()).join('\n')}");

      // Step 3: Display Calendars to the User (You can navigate to a new screen here)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalendarSelectionScreen(
            userId: userId,
            email: email,
            calendars: calendars,
          ),
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
  Future<Map<String, dynamic>> saveSelectedCalendars(
      String userId, googleAccount, List<Calendar> selectedCalendars) async {
    print("Entering saveSelectedCalendars");
    print("UserId: $userId");
    print("Google Account: $googleAccount");
    try {
      await _googleCalendarService.saveSelectedCalendars(
          userId, googleAccount, selectedCalendars);

      return {'success': true, 'message': 'Calendars saved successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to save calendars: $e'};
    }
  }
}
