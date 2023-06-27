import 'package:flutter/material.dart';
import '../../widgets/shared/custom_appbar.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
  }) : super(key: key);

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
                child: Text('Ooops, something happened! Try going back home.')),
          ),
        ),
      ),
    );
  }
}
