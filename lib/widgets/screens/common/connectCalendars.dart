import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:provider/provider.dart';

import '../../shared/customAppbar.dart';
import '../../responsive/responsive_helper.dart';
import '../../responsive/responsive_button.dart';

import '../../../services/googleIntegration/googleSignInManager.dart';
import '../../../services/googleIntegration/calendarSyncManager.dart';
import '../../../services/microsoftIntegration/microsoftSignInManager.dart';
import '../../../services/microsoftIntegration/microsoftAuthService.dart';
import '../../../services/appleIntegration/appleSignInManager.dart';
import '../../../providers/authProvider.dart';
import './calendarSettings.dart';

import 'agenda.dart';

class ConnectCal extends StatelessWidget {
  final String? microsoftAuthCode;

  const ConnectCal({Key? key, this.microsoftAuthCode}) : super(key: key);
  static const routeName = '/connectCalendars';

  @override
  Widget build(BuildContext context) {
    // Remove the ChangeNotifierProvider since it's no longer needed
    return _ConnectCalBody(microsoftAuthCode: microsoftAuthCode);
  }
}

class _ConnectCalBody extends StatefulWidget {
  final String? microsoftAuthCode;

  const _ConnectCalBody({this.microsoftAuthCode});

  @override
  _ConnectCalBodyState createState() => _ConnectCalBodyState();
}

class _ConnectCalBodyState extends State<_ConnectCalBody> {
  bool _processingMicrosoft = false;

  @override
  void initState() {
    super.initState();
    // Handle Microsoft OAuth callback if auth code is present
    if (widget.microsoftAuthCode != null) {
      _handleMicrosoftCallback();
    }
  }

  void startBlank(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(Agenda.routeName);
  }

  void _showAppleInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.apple, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text('iCloud Calendar Setup'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'To connect your iCloud calendar, you need to create an App-Specific Password:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                _buildInstructionStep(
                  '1.',
                  'Go to appleid.apple.com and sign in',
                ),
                _buildInstructionStep(
                  '2.',
                  'Navigate to "Security" section',
                ),
                _buildInstructionStep(
                  '3.',
                  'Find "App-Specific Passwords"',
                ),
                _buildInstructionStep(
                  '4.',
                  'Click "Generate Password"',
                ),
                _buildInstructionStep(
                  '5.',
                  'Enter "Timelyst Calendar" as the label',
                ),
                _buildInstructionStep(
                  '6.',
                  'Copy the generated password (format: xxxx-xxxx-xxxx-xxxx)',
                ),
                _buildInstructionStep(
                  '7.',
                  'Use this password when prompted, NOT your regular Apple ID password',
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Important: You must use the App-Specific Password, not your regular Apple ID password.',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Open Apple ID website
                html.window.open('https://appleid.apple.com', '_blank');
              },
              child: Text('Open Apple ID'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            child: Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMicrosoftCallback() async {
    if (_processingMicrosoft) return; // Prevent duplicate processing

    setState(() {
      _processingMicrosoft = true;
    });

    try {
      print("🔄 [ConnectCalendars] Processing Microsoft OAuth callback");

      // Clean up URL immediately
      html.window.history.replaceState(null, '', '/');

      final signInManager = MicrosoftSignInManager();
      final result =
          await signInManager.handleAuthCallback(widget.microsoftAuthCode!);

      if (result.userId != null && result.calendars != null) {
        print("✅ [ConnectCalendars] Microsoft authentication successful");

        // Refresh auth provider state to sync UI with stored auth tokens
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.refreshAuthState();
          print("🔄 [ConnectCalendars] Auth state refreshed after Microsoft OAuth");
        }

        if (mounted) {
          // Show success feedback before navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 12),
                  Text('Microsoft calendar connected successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to calendar settings - use pushReplacement to prevent going back
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarSettings(
                userId: result.userId!,
                email: result.email!,
                calendars: result.calendars!,
              ),
            ),
          );
        }
      } else {
        throw Exception('Microsoft sign-in failed - no user data returned');
      }
    } catch (e) {
      print('❌ [ConnectCalendars] Microsoft OAuth callback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microsoft sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingMicrosoft = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();
    final mediaQuery = MediaQuery.of(context);

    // Use existing responsive system
    final horizontalPadding = ResponsiveHelper.getValue(
      context,
      mobile: 24.0,
      tablet: 32.0,
      desktop: 64.0,
    );

    final verticalPadding = ResponsiveHelper.getValue(
      context,
      mobile: 32.0,
      tablet: 32.0,
      desktop: 48.0,
    );

    final titleFontSize = ResponsiveHelper.getValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );

    final spacingAfterTitle = ResponsiveHelper.getValue(
      context,
      mobile: 24.0,
      tablet: 36.0,
      desktop: 48.0,
    );

    final spacingBeforeButton = ResponsiveHelper.getValue(
      context,
      mobile: 24.0,
      tablet: 36.0,
      desktop: 48.0,
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: mediaQuery.size.height -
                      (appBar.preferredSize.height + mediaQuery.padding.top),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header section with responsive spacing
                      Container(
                        constraints: BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            SizedBox(
                                height: ResponsiveHelper.getValue(
                              context,
                              mobile: 20.0,
                              tablet: 40.0,
                              desktop: 60.0,
                            )),
                            Text(
                              'Add your external accounts to get a 360 view on your schedules and ToDos.',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontSize: titleFontSize,
                                    height: 1.3,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacingAfterTitle),
                          ],
                        ),
                      ),

                      // Service buttons with responsive layout
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.getValue(
                            context,
                            mobile: 400.0,
                            tablet: 400.0,
                            desktop: 600.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Gmail button with Google red color
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  bottom: ResponsiveHelper.getValue(
                                context,
                                mobile: 12.0,
                                tablet: 14.0,
                                desktop: 16.0,
                              )),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Show initial loading feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                                'Connecting to Google Calendar...'),
                                          ],
                                        ),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    final signInManager = GoogleSignInManager();
                                    final signInResult =
                                        await signInManager.signIn(context);

                                    if (signInResult != null &&
                                        signInResult.calendars != null) {
                                      print(
                                          "✅ [ConnectCalendars] Google authentication successful");

                                      // Refresh auth provider state to sync UI with stored auth tokens
                                      if (context.mounted) {
                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                        await authProvider.refreshAuthState();
                                        print("🔄 [ConnectCalendars] Auth state refreshed after Google OAuth");
                                      }

                                      if (context.mounted) {
                                        // Set up default preferences for all calendars
                                        // Import subject only, with default 'Work' category
                                        final calendarsWithDefaults = signInResult.calendars!.map((calendar) {
                                          return calendar.copyWith(
                                            preferences: calendar.preferences.copyWith(
                                              importSettings: calendar.preferences.importSettings.copyWith(
                                                importAll: false,
                                                importSubject: true,
                                                importBody: false,
                                                importConferenceInfo: false,
                                                importOrganizer: false,
                                                importRecipients: false,
                                              ),
                                              category: 'Work', // Default category
                                            ),
                                          );
                                        }).toList();

                                        print("🔄 [ConnectCalendars] Saving ${calendarsWithDefaults.length} calendars with default settings...");

                                        // Save calendars immediately with default preferences
                                        try {
                                          final syncManager = CalendarSyncManager();
                                          final saveResult = await syncManager.saveSelectedCalendars(
                                            userId: signInResult.userId,
                                            email: signInResult.email,
                                            selectedCalendars: calendarsWithDefaults,
                                          );

                                          if (saveResult.success) {
                                            print("✅ [ConnectCalendars] Calendars saved successfully, redirecting to Agenda");

                                            // Navigate directly to Agenda with sync in progress
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Agenda(
                                                  calendars: calendarsWithDefaults,
                                                  userId: signInResult.userId,
                                                  email: signInResult.email,
                                                  syncInProgress: true,
                                                  syncIntegrationType: 'GOOGLE',
                                                ),
                                              ),
                                            );
                                          } else {
                                            throw Exception(saveResult.error ?? 'Failed to save calendars');
                                          }
                                        } catch (e) {
                                          print("❌ [ConnectCalendars] Failed to save calendars: $e");
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed to save calendar settings: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 5),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        print(
                                            '⚠️ [ConnectCalendars] Context not mounted - cannot navigate');
                                      }
                                    } else if (signInResult != null &&
                                        context.mounted) {
                                      print(
                                          '⚠️ [ConnectCalendars] Sign-in successful but no calendars found');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'No calendars found. Please check your Google Calendar settings.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    } else {
                                      print(
                                          '❌ [ConnectCalendars] Sign-in failed or was cancelled by user');
                                    }
                                  } catch (e) {
                                    print(
                                        '❌ [ConnectCalendars] Exception during Google sign-in: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Google sign-in failed: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFFEA4335), // Google red
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 18.0,
                                      desktop: 20.0,
                                    ),
                                    horizontal: 24.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'Gmail',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 17.0,
                                      desktop: 18.0,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Outlook button with Microsoft blue color
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  bottom: ResponsiveHelper.getValue(
                                context,
                                mobile: 12.0,
                                tablet: 14.0,
                                desktop: 16.0,
                              )),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Show initial loading feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                                'Redirecting to Microsoft login...'),
                                          ],
                                        ),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    print(
                                        "🔄 [ConnectCalendars] Starting Microsoft OAuth flow");

                                    // Generate Microsoft OAuth URL and navigate in same tab
                                    final authService = MicrosoftAuthService();
                                    final authUrl =
                                        await authService.generateAuthUrl();

                                    // Ensure redirect happens in same window, not new tab
                                    // Use location.replace to avoid back button issues
                                    html.window.location.replace(authUrl);
                                  } catch (e) {
                                    print(
                                        '❌ [ConnectCalendars] Exception during Microsoft OAuth: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Microsoft sign-in failed: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFF0078D4), // Microsoft blue
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 18.0,
                                      desktop: 20.0,
                                    ),
                                    horizontal: 24.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'Outlook',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 17.0,
                                      desktop: 18.0,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // iCloud button with steel grey color
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  bottom: ResponsiveHelper.getValue(
                                context,
                                mobile: 12.0,
                                tablet: 14.0,
                                desktop: 16.0,
                              )),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Show initial loading feedback
                                    print(
                                        '🔍 [ConnectCalendars] SHOWING APPLE CONNECTION SNACKBAR');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                                'Connecting to iCloud Calendar...'),
                                          ],
                                        ),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    final signInManager = AppleSignInManager();
                                    final signInResult =
                                        await signInManager.signIn(context);

                                    if (signInResult.userId != null &&
                                        signInResult.calendars != null) {
                                      print(
                                          "✅ [ConnectCalendars] Apple authentication successful");

                                      // Refresh auth provider state to sync UI with stored auth tokens
                                      if (context.mounted) {
                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                        await authProvider.refreshAuthState();
                                        print("🔄 [ConnectCalendars] Auth state refreshed after Apple OAuth");
                                      }

                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CalendarSettings(
                                              userId: signInResult.userId!,
                                              email: signInResult.email!,
                                              calendars:
                                                  signInResult.calendars!,
                                            ),
                                          ),
                                        );
                                      } else {
                                        print(
                                            '⚠️ [ConnectCalendars] Context not mounted - cannot navigate');
                                      }
                                    } else if (signInResult.userId != null &&
                                        context.mounted) {
                                      print(
                                          '⚠️ [ConnectCalendars] Apple sign-in successful but no calendars found');
                                      print(
                                          '🔍 [ConnectCalendars] SHOWING NO CALENDARS SNACKBAR');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'No calendars found. Please check your iCloud Calendar settings.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    } else {
                                      print(
                                          '❌ [ConnectCalendars] Apple sign-in failed or was cancelled by user');
                                    }
                                  } catch (e) {
                                    print(
                                        '❌ [ConnectCalendars] Exception during Apple sign-in: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Apple sign-in failed: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFF6C757D), // Steel grey
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 18.0,
                                      desktop: 20.0,
                                    ),
                                    horizontal: 24.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'iCloud',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getValue(
                                      context,
                                      mobile: 16.0,
                                      tablet: 17.0,
                                      desktop: 18.0,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Start blank button with responsive spacing
                            Padding(
                              padding:
                                  EdgeInsets.only(top: spacingBeforeButton),
                              child: TextButton(
                                onPressed: () {
                                  print('Start Blank button pressed');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Agenda()),
                                  );
                                },
                                child: Text(
                                  'Start Blank',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontSize: ResponsiveHelper.getValue(
                                          context,
                                          mobile: 16.0,
                                          tablet: 18.0,
                                          desktop: 20.0,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading overlay for Microsoft callback processing
            if (_processingMicrosoft)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Processing Microsoft authorization...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please wait while we connect your calendar',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
