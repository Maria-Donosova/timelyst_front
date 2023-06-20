import 'package:flutter/material.dart';
import '../../widgets/shared/custom_appbar.dart';
import '../layout/left_panel.dart';
import '../layout/right_panel.dart';

class Agenda extends StatelessWidget {
  const Agenda({Key? key}) : super(key: key);
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
              ? Container(
                  width: mediaQuery.size.width * 0.43,
                  // height: (mediaQuery.size.height -
                  //         appBar.preferredSize.height -
                  //         mediaQuery.padding.top) *
                  //     0.96,
                  child: const LeftPanel(),
                )
              : Container(
                  width: mediaQuery.size.width * 0.28,
                  // height: (mediaQuery.size.height -
                  //         appBar.preferredSize.height -
                  //         mediaQuery.padding.top) *
                  //     0.97,
                  child: const LeftPanel(),
                ),
          !isLandscape
              ? Container(
                  width: mediaQuery.size.width * 0.57,
                  child: const RightPanel(),
                )
              : Container(
                  width: mediaQuery.size.width * 0.61,
                  child: const RightPanel(),
                ),
        ]),
      ),
    );
  }
}
