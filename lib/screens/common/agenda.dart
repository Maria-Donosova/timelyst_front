import 'package:flutter/material.dart';
import '../../widgets/shared/custom_appbar.dart';
import '../../widgets/layout/left_panel.dart';
import '../../widgets/layout/right_panel.dart';

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
              ? Expanded(flex: 1, child: LeftPanel())
              : Expanded(flex: 1, child: LeftPanel()),
          !isLandscape
              ? Expanded(
                  //width: mediaQuery.size.width * 0.57,
                  flex: 2,
                  child: const RightPanel(),
                )
              : Expanded(
                  //width: mediaQuery.size.width * 0.61,
                  flex: 2,
                  child: const RightPanel(),
                ),
        ]),
      ),
    );
  }
}



// void initState() {
//    super.initState();

// _googleSignIn.onCurrentUserChanged
//     .listen((GoogleSignInAccount? account) async {
//   if (kIsWeb && account != null) {
//     bool isAuthorized = await _googleSignIn.canAccessScopes([
//       'your scopes'
//     ]);

//     if (!isAuthorized) {
//       await _googleSignIn.requestScopes([
//         'your scopes'
//       ]);
//     }
//   }
// });

// if (kIsWeb) {
//   _googleSignIn.signInSilently();
// }
// }