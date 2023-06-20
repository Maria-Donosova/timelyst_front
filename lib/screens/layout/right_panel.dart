import 'package:flutter/material.dart';

import '../../widgets/calendar/calendar.dart';

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
            children: [
              !isLandscape
                  ? Container(
                      //not used at all
                      //height: constraints.maxHeight * 0.04,
                      //fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                      child: Container(),
                    )
                  : FittedBox(
                      //not used at all
                      //height: constraints.maxHeight * 0.09,
                      alignment: Alignment.bottomLeft,
                      child: Container(),
                    ),
              !isLandscape
                  ? Container(
                      height: constraints.maxHeight * 0.98, //vertical view
                      alignment: Alignment.bottomLeft,
                      child: CalendarW(),
                    )
                  : Container(
                      height: constraints.maxHeight * 0.6, // horizontal view
                      child: CalendarW(),
                    ),
            ],
          ),
        );
      },
    );
  }
}
