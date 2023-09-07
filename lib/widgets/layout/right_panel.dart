import 'package:flutter/material.dart';

import '../calendar/calendar.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              !isLandscape
                  ? Flexible(flex: 0, child: Container())
                  : Flexible(
                      flex: 0,
                      child: Container(),
                    ),
              !isLandscape
                  ? Flexible(
                      child: CalendarW(),
                    )
                  : Flexible(
                      child: CalendarW(),
                    ),
            ],
          ),
        );
      },
    );
  }
}
