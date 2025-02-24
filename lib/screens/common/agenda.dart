import 'package:flutter/material.dart';
import '../../widgets/shared/customAppbar.dart';
import '../../widgets/layout/left_panel.dart';
import '../../widgets/layout/right_panel.dart';

class Agenda extends StatelessWidget {
  const Agenda({
    Key? key,
    calendars,
    userId,
    email,
  }) : super(key: key);
  static const routeName = '/tasks-month-calendar';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          !isLandscape
              ? Expanded(flex: 1, child: LeftPanel())
              : Expanded(flex: 1, child: LeftPanel()),
          !isLandscape
              ? Expanded(
                  flex: 2,
                  child: const RightPanel(),
                )
              : Expanded(
                  flex: 2,
                  child: const RightPanel(),
                ),
        ]),
      ),
    );
  }
}
