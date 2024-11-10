import 'package:flutter/material.dart';
import '../../widgets/shared/custom_appbar.dart';

import 'agenda.dart';
import 'agenda_settings.dart';

class ConnectCal extends StatelessWidget {
  const ConnectCal({Key? key}) : super(key: key);
  static const routeName = '/connect-screen';

  void startBlank(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      Agenda.routeName,
    );
  }

  void connectDummy(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      AgendaSettings.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    //final mediaQuery = MediaQuery.of(context);
    //final isLandscape = mediaQuery.orientation == Orientation.landscape;
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
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Connect',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Gmail button pressed');
                      // connectDummy(context);
                      // print('connected!');
                    },
                    child: const Text('Gmail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 198, 23, 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Outlook button pressed');
                      // connectDummy(context);
                      // print('connected!');
                    },
                    child: const Text('Outlook'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 6, 117, 208),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('iCloud button pressed');
                      // connectDummy(context);
                      // print('connected!');
                    },
                    child: const Text('iCloud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 41, 41, 41),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: TextButton(
                    onPressed: () {
                      print('Start Blank button pressed');
                      //startBlank(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Agenda()),
                      );
                    },
                    child: Text('Or Start Blank',
                        style: Theme.of(context).textTheme.bodyLarge),
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
