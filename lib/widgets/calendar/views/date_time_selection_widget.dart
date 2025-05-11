import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelectionWidget extends StatefulWidget {
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeSelected;
  final String labelText;
  final bool showTime;

  const DateTimeSelectionWidget({
    Key? key,
    required this.initialDateTime,
    required this.onDateTimeSelected,
    required this.labelText,
    this.showTime = true,
  }) : super(key: key);

  @override
  State<DateTimeSelectionWidget> createState() =>
      _DateTimeSelectionWidgetState();
}

class _DateTimeSelectionWidgetState extends State<DateTimeSelectionWidget> {
  late DateTime _selectedDateTime;
  final DateFormat _dateFormat = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDateTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.showTime
                  ? '${_dateFormat.format(_selectedDateTime)} at ${_timeFormat.format(_selectedDateTime)}'
                  : _dateFormat.format(_selectedDateTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime;

      if (widget.showTime) {
        pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        );
      }

      setState(() {
        if (widget.showTime && pickedTime != null) {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        }
      });

      widget.onDateTimeSelected(_selectedDateTime);
    }
  }
}
