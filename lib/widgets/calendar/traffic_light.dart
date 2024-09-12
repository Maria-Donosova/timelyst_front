import 'package:flutter/material.dart';

class TrafficLightW extends StatelessWidget {
  const TrafficLightW({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircleAvatar(
          backgroundColor: Colors.red,
          radius: 6,
        ),
        CircleAvatar(
          backgroundColor: Colors.yellow,
          radius: 6,
        ),
        CircleAvatar(
          backgroundColor: Colors.green,
          radius: 6,
        ),
      ],
    );
  }
}
