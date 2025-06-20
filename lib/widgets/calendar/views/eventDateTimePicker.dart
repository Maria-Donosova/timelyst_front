import 'package:flutter/material.dart';

class EventDateTimePicker extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final bool allDay;
  final ValueChanged<bool> onAllDayChanged;
  final VoidCallback onDateSelected;
  final VoidCallback onStartTimeSelected;
  final VoidCallback onEndTimeSelected;

  const EventDateTimePicker({
    Key? key,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.allDay,
    required this.onAllDayChanged,
    required this.onDateSelected,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildDateField(context),
        _buildTimeField(
            context, startTimeController, 'Begin', onStartTimeSelected),
        _buildTimeField(context, endTimeController, 'End', onEndTimeSelected),
        _buildAllDayButton(context),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        controller: dateController,
        decoration: const InputDecoration(labelText: 'Date'),
        onTap: onDateSelected,
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    TextEditingController controller,
    String label,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAllDayButton(BuildContext context) {
    return IconButton(
      icon: Icon(allDay ? Icons.hourglass_full : Icons.hourglass_empty),
      color: allDay
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      onPressed: () => onAllDayChanged(!allDay),
      tooltip: "All Day",
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DateTimeSelectionWidget extends StatefulWidget {
//   final DateTime initialDateTime;
//   final Function(DateTime) onDateTimeSelected;
//   final String labelText;
//   final bool showTime;

//   const DateTimeSelectionWidget({
//     Key? key,
//     required this.initialDateTime,
//     required this.onDateTimeSelected,
//     required this.labelText,
//     this.showTime = true,
//   }) : super(key: key);

//   @override
//   State<DateTimeSelectionWidget> createState() =>
//       _DateTimeSelectionWidgetState();
// }

// class _DateTimeSelectionWidgetState extends State<DateTimeSelectionWidget> {
//   late DateTime _selectedDateTime;
//   final DateFormat _dateFormat = DateFormat('EEE, MMM d, yyyy');
//   final DateFormat _timeFormat = DateFormat('h:mm a');

//   @override
//   void initState() {
//     super.initState();
//     _selectedDateTime = widget.initialDateTime;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Entering date time selection widget");
//     return InkWell(
//       onTap: () => _selectDateTime(context),
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: widget.labelText,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               widget.showTime
//                   ? '${_dateFormat.format(_selectedDateTime)} at ${_timeFormat.format(_selectedDateTime)}'
//                   : _dateFormat.format(_selectedDateTime),
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             Icon(
//               Icons.calendar_today,
//               size: 16,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDateTime(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDateTime,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       TimeOfDay? pickedTime;

//       if (widget.showTime) {
//         pickedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
//         );
//       }

//       setState(() {
//         if (widget.showTime && pickedTime != null) {
//           _selectedDateTime = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         } else {
//           _selectedDateTime = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             _selectedDateTime.hour,
//             _selectedDateTime.minute,
//           );
//         }
//       });

//       widget.onDateTimeSelected(_selectedDateTime);
//     }
//   }
// }
