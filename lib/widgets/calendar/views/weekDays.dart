import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';

class WeekDaysW extends StatelessWidget {
  const WeekDaysW({
    Key? key,
    required this.cellWidth,
    required this.dayNames,
  }) : super(key: key);

  final double? cellWidth;
  final List<String> dayNames;

  @override
  Widget build(BuildContext context) {
    final double fontSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobileValue: 10.0,
      tabletValue: 12.0,
      desktopValue: 14.0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 20),
        ...dayNames.map((name) => Container(
              width: cellWidth,
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: fontSize,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
    );
  }
}
