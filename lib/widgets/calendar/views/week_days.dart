import 'package:flutter/material.dart';

class WeekDaysW extends StatelessWidget {
  const WeekDaysW({
    Key? key,
    required this.cellWidth,
    required String? viewHeaderText6,
    required String? viewHeaderText,
    required String? viewHeaderText1,
    required String? viewHeaderText2,
    required String? viewHeaderText3,
    required String? viewHeaderText4,
    required String? viewHeaderText5,
  })  : _viewHeaderText6 = viewHeaderText6,
        _viewHeaderText = viewHeaderText,
        _viewHeaderText1 = viewHeaderText1,
        _viewHeaderText2 = viewHeaderText2,
        _viewHeaderText3 = viewHeaderText3,
        _viewHeaderText4 = viewHeaderText4,
        _viewHeaderText5 = viewHeaderText5,
        super(key: key);

  final double? cellWidth;
  final String? _viewHeaderText6;
  final String? _viewHeaderText;
  final String? _viewHeaderText1;
  final String? _viewHeaderText2;
  final String? _viewHeaderText3;
  final String? _viewHeaderText4;
  final String? _viewHeaderText5;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(width: 20, child: Text('')),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText6!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText1!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText2!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText3!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText4!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: cellWidth,
          child: Text(
            _viewHeaderText5!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
