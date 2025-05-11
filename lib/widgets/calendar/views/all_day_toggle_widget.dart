import 'package:flutter/material.dart';

class AllDayToggleWidget extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onToggled;

  const AllDayToggleWidget({
    Key? key,
    required this.initialValue,
    required this.onToggled,
  }) : super(key: key);

  @override
  State<AllDayToggleWidget> createState() => _AllDayToggleWidgetState();
}

class _AllDayToggleWidgetState extends State<AllDayToggleWidget> {
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _isAllDay = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'All Day',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Switch(
          value: _isAllDay,
          onChanged: (value) {
            setState(() {
              _isAllDay = value;
            });
            widget.onToggled(value);
          },
        ),
      ],
    );
  }
}
