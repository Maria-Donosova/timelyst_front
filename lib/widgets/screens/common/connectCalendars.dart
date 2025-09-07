import 'package:flutter/material.dart';

import '../../shared/customAppbar.dart';

import '../../../services/googleIntegration/googleSignInManager.dart';
import './calendarSettings.dart';

import 'agenda.dart';

class ConnectCal extends StatelessWidget {
  const ConnectCal({Key? key}) : super(key: key);
  static const routeName = '/connectCalendars';

  @override
  Widget build(BuildContext context) {
    // Remove the ChangeNotifierProvider since it's no longer needed
    return _ConnectCalBody();
  }
}

class _ConnectCalBody extends StatelessWidget {
  void startBlank(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(Agenda.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Container(
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
                  onPressed: () {
                    print('Outlook button pressed');
                    // Implement Outlook connection
                  },
                ),
                _ServiceButton(
                  text: 'iCloud',
                  color: const Color.fromARGB(255, 41, 41, 41),
                  onPressed: () {
                    print('iCloud button pressed');
                    // Implement iCloud connection
                  },
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
