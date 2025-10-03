import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../../shared/customAppbar.dart';

import '../../../services/googleIntegration/googleSignInManager.dart';
import '../../../services/microsoftIntegration/microsoftSignInManager.dart';
import '../../../services/microsoftIntegration/microsoftAuthService.dart';
import '../../../services/appleIntegration/appleSignInManager.dart';
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
                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
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
      print('🔍 [ConnectCalendars] Processing Microsoft OAuth callback');
      
      // Clean up URL immediately
      html.window.history.replaceState(null, '', '/');
      
      final signInManager = MicrosoftSignInManager();
      final result = await signInManager.handleAuthCallback(widget.microsoftAuthCode!);
      
      if (result.userId != null && result.calendars != null) {
        print('✅ [ConnectCalendars] Microsoft sign-in successful with ${result.calendars!.length} calendars');
        
        if (mounted) {
          // Navigate to calendar settings - same as other providers
          Navigator.push(
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

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 150.0, left: 10, right: 10),
                  child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 90, bottom: 30.0),
                  child: Text(
                    'Add your external accounts to get a 360 view on your schedules and ToDos.',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                _ServiceButton(
                  text: 'Gmail',
                  color: const Color.fromARGB(255, 198, 23, 10),
                  onPressed: () async {
                    print('🔍 [ConnectCalendars] Gmail button pressed by user');
                    final signInManager = GoogleSignInManager();
                    print('🔍 [ConnectCalendars] GoogleSignInManager created');
                    
                    final signInResult = await signInManager.signIn(context);
                    print('🔍 [ConnectCalendars] Sign-in result received: ${signInResult != null ? 'SUCCESS' : 'FAILED'}');

                    if (signInResult != null && signInResult.calendars != null) {
                      print('✅ [ConnectCalendars] Sign-in successful with ${signInResult.calendars!.length} calendars');
                      print('🔍 [ConnectCalendars] User: ${signInResult.email} (${signInResult.userId})');
                      
                      if (context.mounted) {
                        print('🔍 [ConnectCalendars] Navigating to CalendarSettings...');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarSettings(
                              userId: signInResult.userId,
                              email: signInResult.email,
                              calendars: signInResult.calendars!,
                            ),
                          ),
                        );
                      } else {
                        print('⚠️ [ConnectCalendars] Context not mounted - cannot navigate');
                      }
                    } else if (signInResult != null && context.mounted) {
                      print('⚠️ [ConnectCalendars] Sign-in successful but no calendars found');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'No calendars found. Please check your Google Calendar settings.'),
                        ),
                      );
                    } else {
                      print('❌ [ConnectCalendars] Sign-in failed or was cancelled by user');
                    }
                  },
                ),
                _ServiceButton(
                  text: 'Outlook',
                  color: const Color.fromARGB(255, 6, 117, 208),
                  onPressed: () async {
                    print('🔍 [ConnectCalendars] Outlook button pressed by user');
                    
                    try {
                      // Generate Microsoft OAuth URL and navigate in same tab
                      final authService = MicrosoftAuthService();
                      final authUrl = authService.generateAuthUrl();
                      print('🔍 [ConnectCalendars] Generated Microsoft OAuth URL');
                      
                      // Navigate to OAuth URL in same tab (like Google flow)
                      html.window.location.href = authUrl;
                      
                    } catch (e) {
                      print('❌ [ConnectCalendars] Exception during Microsoft OAuth: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Microsoft sign-in failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ServiceButton(
                      text: 'iCloud',
                      color: const Color.fromARGB(255, 41, 41, 41),
                      onPressed: () async {
                        print('🔍 [ConnectCalendars] iCloud button pressed by user');
                        final signInManager = AppleSignInManager();
                        print('🔍 [ConnectCalendars] AppleSignInManager created');
                        
                        try {
                          final signInResult = await signInManager.signIn(context);
                          print('🔍 [ConnectCalendars] Apple sign-in result received: ${signInResult.userId != null ? 'SUCCESS' : 'FAILED'}');

                          if (signInResult.userId != null && signInResult.calendars != null) {
                            print('✅ [ConnectCalendars] Apple sign-in successful with ${signInResult.calendars!.length} calendars');
                            print('🔍 [ConnectCalendars] User: ${signInResult.email} (${signInResult.userId})');
                            
                            if (context.mounted) {
                              print('🔍 [ConnectCalendars] Navigating to CalendarSettings...');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarSettings(
                                    userId: signInResult.userId!,
                                    email: signInResult.email!,
                                    calendars: signInResult.calendars!,
                                  ),
                                ),
                              );
                            } else {
                              print('⚠️ [ConnectCalendars] Context not mounted - cannot navigate');
                            }
                          } else if (signInResult.userId != null && context.mounted) {
                            print('⚠️ [ConnectCalendars] Apple sign-in successful but no calendars found');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'No calendars found. Please check your iCloud Calendar settings.'),
                              ),
                            );
                          } else {
                            print('❌ [ConnectCalendars] Apple sign-in failed or was cancelled by user');
                          }
                        } catch (e) {
                          print('❌ [ConnectCalendars] Exception during Apple sign-in: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Apple sign-in failed: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () => _showAppleInstructions(context),
                      tooltip: 'How to set up iCloud calendar',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: TextButton(
                    onPressed: () {
                      print('Start Blank button pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Agenda()),
                      );
                    },
                    child: Text(
                      'Start Blank',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                ),
              ]),
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

class _ServiceButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ServiceButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(text),
      ),
    );
  }
}
