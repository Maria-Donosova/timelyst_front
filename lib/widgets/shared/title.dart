import 'package:flutter/material.dart';

class TitleW extends StatelessWidget {
  const TitleW({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(bottom: 1),
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 21, bottom: 1),
        child: Text(
          'ToDo',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
