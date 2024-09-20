// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   testWidgets('monthCellBuilder returns a Card', () {
//     final context = MaterialApp().buildContext();
//     final monthCellDetails = MonthCellDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 1),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     expect(monthCellBuilder(context, monthCellDetails), isA<Container>());
//   });

//   testWidgets('monthCellBuilder calls functions with correct context', () {
//     final context = MaterialApp().buildContext();
//     final monthCellDetails = MonthCellDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 1),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     expect(() => monthCellBuilder(context, monthCellDetails), 
//         returnsNormally);
//   });

//   testWidgets('monthCellBuilder uses correct width', () {
//     final context = MaterialApp().buildContext();
//     final monthCellDetails = MonthCellDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 1),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     final width = StatefulBuilder(
//       builder: (context, setState) {
//         final width = MediaQuery.of(context).size.width;
//         setState(() {});
//         return width;
//       },
//     );
//     expect(() => monthCellBuilder(context, monthCellDetails), isNotNull);
//   });

//   testWidgets('appointmentBuilder returns a Card when appointment has a single day duration', () {
//     final context = MaterialApp().buildContext();
//     final calendarAppointmentDetails = CalendarAppointmentDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 1),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     expect(appointmentBuilder(context, calendarAppointmentDetails), isA<Container>());
//   });

//   testWidgets('appointmentBuilder returns a colored rectangle when appointment has a multi-day duration', () {
//     final context = MaterialApp().buildContext();
//     final calendarAppointmentDetails = CalendarAppointmentDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 12, 31),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     expect(appointmentBuilder(context, calendarAppointmentDetails), isA<Container>());
//   });

//   testWidgets('appointmentBuilder uses correct context', () {
//     final context = MaterialApp().buildContext();
//     final calendarAppointmentDetails = CalendarAppointmentDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 31),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     expect(() => appointmentBuilder(context, calendarAppointmentDetails), returnsNormally);
//   });

//   testWidgets('appointmentBuilder uses correct width', () {
//     final context = MaterialApp().buildContext();
//     final calendarAppointmentDetails = CalendarAppointmentDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 1, 31),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     final width = StatefulBuilder(
//       builder: (context, setState) {
//         final width = MediaQuery.of(context).size.width;
//         setState(() {});
//         return width;
//       },
//     );
//     expect(() => appointmentBuilder(context, calendarAppointmentDetails), isNotNull);
//   });

//   testWidgets('appointmentBuilder uses correct width even for multi-day duration', () {
//     final context = MaterialApp().buildContext();
//     final calendarAppointmentDetails = CalendarAppointmentDetails(
//       appointments: [
//         CustomAppointment(
//           startTime: DateTime(2022, 1, 1),
//           endTime: DateTime(2022, 12, 31),
//           subject: 'Test Event',
//           catTitle: 'Category',
//         ),
//       ],
//     );
//     final width = StatefulBuilder(
//       builder: (context, setState) {
//         final width = MediaQuery.of(context).size.width;
//         setState(() {});
//         return width;
//       },
//     );
//     expect(() => appointmentBuilder(context, calendarAppointmentDetails), isNotNull);
//   });
// }