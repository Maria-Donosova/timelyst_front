import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleCalDAVManager.dart';
import 'package:timelyst_flutter/widgets/calendar/appleCalendarConnectionForm.dart';
import 'package:timelyst_flutter/models/calendars.dart';

/// Updated Apple Sign-In Manager using CalDAV authentication
/// Maintains the same interface but uses Apple ID + App-Specific Password instead of OAuth
class AppleSignInManager {
  final AppleCalDAVManager _calDAVManager;

  AppleSignInManager({
    AppleCalDAVManager? calDAVManager,
  }) : _calDAVManager = calDAVManager ?? AppleCalDAVManager();

  /// Shows Apple Calendar connection form instead of OAuth flow
  Future<AppleSignInResult> signIn(BuildContext context) async {
    try {

      final completer = Completer<AppleSignInResult>();

      // Show the Apple Calendar connection form
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: AppleCalendarConnectionForm(
              onSuccess: (result) {
                Navigator.of(dialogContext).pop();
                completer.complete(result);
              },
              onError: (error) {
                Navigator.of(dialogContext).pop();
                completer.completeError(Exception(error));
              },
              onCancel: () {
                Navigator.of(dialogContext).pop();
                completer.completeError(Exception('User cancelled Apple Calendar connection'));
              },
            ),
          );
        },
      );

      final result = await completer.future;
      return result;

    } catch (e) {
      print('❌ [AppleSignInManager] Error during Apple Calendar connection: $e');
      rethrow;
    }
  }

  /// Handles calendar saving (replaces auth callback)
  Future<void> saveSelectedCalendars({
    required String email,
    required List<Map<String, dynamic>> selectedCalendars,
  }) async {
    try {
      
      await _calDAVManager.saveSelectedCalendars(
        email: email,
        selectedCalendars: selectedCalendars,
      );
      
    } catch (e) {
      print('❌ [AppleSignInManager] Error saving calendars: $e');
      rethrow;
    }
  }

  /// Fetches calendars for an email
  Future<List<Calendar>> fetchCalendars(String email) async {
    try {
      
      final calendars = await _calDAVManager.fetchCalendars(email);
      
      return calendars;
    } catch (e) {
      print('❌ [AppleSignInManager] Error fetching calendars: $e');
      rethrow;
    }
  }

  /// Disconnects Apple Calendar account
  Future<void> signOut({String? email}) async {
    try {
      
      if (email != null) {
        await _calDAVManager.disconnectAccount(email);
      } else {
        await _calDAVManager.deleteCalendars();
      }
      
    } catch (e) {
      print('❌ [AppleSignInManager] Error during disconnect: $e');
      rethrow;
    }
  }
}