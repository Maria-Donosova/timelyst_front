import 'package:flutter/material.dart';

class EventOfDayW extends StatelessWidget {
  final String? eventOfDay;

  const EventOfDayW({
    Key? key,
    required this.eventOfDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Container(
        width: width,
        color: const Color.fromRGBO(238, 243, 246, 1.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            eventOfDay!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
