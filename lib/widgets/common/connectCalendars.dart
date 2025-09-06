import 'package:flutter/material.dart';

import '../shared/customAppbar.dart';
import '../../services/googleIntegration/googleCalendarService.dart';
import '../../services/googleIntegration/googleSignInManager.dart';
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
                    print('Gmail button pressed');
                    final signInManager = GoogleSignInManager();
                    final signInResult = await signInManager.signIn(context);

                    if (signInResult != null && signInResult.authCode != null) {
                      final calendarService = GoogleCalendarService();
                      final calendars = await calendarService.firstCalendarFetch(
                        authCode: signInResult.authCode!,
                        email: signInResult.email,
                      );

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarSettings(
                              userId: signInResult.userId,
                              email: signInResult.email,
                              calendars: calendars,
                            ),
                          ),
                        );
                      }
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
