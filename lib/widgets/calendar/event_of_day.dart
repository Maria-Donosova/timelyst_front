import 'package:flutter/material.dart';

class EventOfDayW extends StatelessWidget {
  const EventOfDayW({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'The event of the day',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[900],
        fontSize: 14,
      ),
    );
  }
}
