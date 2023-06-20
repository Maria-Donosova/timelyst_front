// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// import 'dart:collection';
// import 'dart:math';
// import 'package:intl/intl.dart';

// import 'package:syncfusion_flutter_calendar/calendar.dart';

// //import 'package:graphql_flutter/graphql_flutter.dart';

// //import '../../utilities/index.dart';

// enum _calView { day, week, month }

// class CalendarWidget extends StatefulWidget {
//   const CalendarWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<CalendarWidget> createState() => _CalendarWidgetState();
// }

// class _CalendarWidgetState extends State<CalendarWidget> {
//   //late Query querySnapshot;

//   CalendarController _controller = CalendarController();

//   final _appForm = GlobalKey<FormState>();

//   //final bool _isSaving = false;

//   final _eventSubjController = TextEditingController();
//   //final _eventSourceController = TextEditingController();
//   final _eventStartDateController = TextEditingController();
//   final _eventEndDateController = TextEditingController();

//   late String eventSubj;
//   // late Float eventStartDate;
//   // late Float eventEndDate;

//   String? _headerText;
//   String? date;
//   double? width, cellWidth;

//   //Function to display week days abreviations
//   //void _showWeekDays() {}

//   List events = [];

//   @override
//   void initState() {
//     _headerText = 'header';
//     _controller = CalendarController();

//     width = 0.0;
//     cellWidth = 0.0;

//     // _getEvents().then((results) {
//     //   setState(() {
//     //     if (results != null) {
//     //       querySnapshot = results;
//     //     }
//     //   });
//     // });
//     // super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final isMonth = _controller.view == CalendarView.month;
//     //final isWeek = _controller.view == CalendarView.week;
//     final mediaQuery = MediaQuery.of(context);
//     width = MediaQuery.of(context).size.width;
//     cellWidth = width! / 16;
//     return Card(
//       // ignore: sort_child_properties_last
//       child: Column(
//         children: [
//           Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Padding(
//                     padding: const EdgeInsets.only(right: 6.0),
//                     child: SizedBox(
//                       //height: 12,
//                       width: 12,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.stop_circle_outlined,
//                           color: Color.fromRGBO(64, 64, 64, 0.2),
//                         ),
//                         onPressed: null,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: mediaQuery.size.width * 0.34,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 10.0, right: 20),
//                       child: Text(
//                         _headerText!,
//                         style: Theme.of(context).textTheme.headline1,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: mediaQuery.size.width * 0.032,
//                     child: IconButton(
//                       iconSize: 16,
//                       color: Colors.grey[800],
//                       icon: const Icon(Icons.arrow_back),
//                       onPressed: () {
//                         _controller.backward!();
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: mediaQuery.size.width * 0.04,
//                     child: IconButton(
//                       iconSize: 16,
//                       color: Colors.grey[800],
//                       icon: const Icon(Icons.arrow_forward),
//                       onPressed: () {
//                         _controller.forward!();
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 4, left: 6),
//                     child: SizedBox(
//                       width: mediaQuery.size.width * 0.04,
//                       child: PopupMenuButton(
//                         icon: Icon(
//                           Icons.calendar_today_outlined,
//                           color: Colors.grey[800],
//                         ),
//                         iconSize: 16,
//                         elevation: 8,
//                         itemBuilder: (BuildContext context) =>
//                             <PopupMenuEntry<_calView>>[
//                           const PopupMenuItem<_calView>(
//                             value: _calView.day,
//                             child: Text('Day'),
//                           ),
//                           const PopupMenuItem<_calView>(
//                             value: _calView.week,
//                             child: Text('Week'),
//                           ),
//                           const PopupMenuItem<_calView>(
//                             value: _calView.month,
//                             child: Text('Month'),
//                           ),
//                         ],
//                         onSelected: (value) {
//                           setState(() {
//                             if (value == _calView.day) {
//                               _controller.view = CalendarView.day;
//                             } else if (value == _calView.week) {
//                               _controller.view = CalendarView.week;
//                             } else if (value == _calView.month) {
//                               _controller.view = CalendarView.month;
//                             }
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: width,
//                 color: const Color.fromRGBO(238, 243, 246, 1.0),
//                 //   child: const Padding(
//                 //     padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//                 //     child: event_of_day(),
//                 //   ),
//                 // ),
//                 // isMonth
//                 //     ? Padding(
//                 //         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 //         child: week_days(
//                 //             cellWidth: cellWidth,
//                 //             viewHeaderText6: 'Sun',
//                 //             viewHeaderText: 'Mon',
//                 //             viewHeaderText1: 'Tue',
//                 //             viewHeaderText2: 'Wed',
//                 //             viewHeaderText3: 'Thu',
//                 //             viewHeaderText4: 'Fri',
//                 //             viewHeaderText5: 'Sat'),
//                 //       )
//                 //     : isWeek
//                 //         ? const Padding(
//                 //             padding: EdgeInsets.symmetric(vertical: 8.0),
//                 //             child: week_days(
//                 //                 cellWidth: 7,
//                 //                 viewHeaderText6: 'S',
//                 //                 viewHeaderText: 'M',
//                 //                 viewHeaderText1: 'T',
//                 //                 viewHeaderText2: 'W',
//                 //                 viewHeaderText3: 'T',
//                 //                 viewHeaderText4: 'F',
//                 //                 viewHeaderText5: 'S'),
//                 //           )
//                 //   : Container(),
//                 //],
//               ),
//               Expanded(
//                 child:
//                     //Query(
//                     //         options: QueryOptions(
//                     //           document: gql(_getEvents),
//                     //           cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
//                     //           pollInterval: const Duration(seconds: 5),
//                     //           fetchPolicy: FetchPolicy.cacheAndNetwork,
//                     //         ),
//                     //         builder: (QueryResult result,
//                     //             {VoidCallback? refetch, FetchMore? fetchMore}) {
//                     //           if (result.hasException) {
//                     //             return Text(result.exception.toString());
//                     //           }
//                     //           if (result.isLoading) {
//                     //             return const CircularProgressIndicator();
//                     //           }
//                     //           events = result.data!["events"];
//                     //           return
//                     SfCalendar(
//                   view: CalendarView.month,
//                   //dataSource: _getCalendarDataSource(),
//                   allowedViews: const [
//                     CalendarView.week,
//                     CalendarView.day,
//                     CalendarView.month
//                   ],
//                   controller: _controller,
//                   timeSlotViewSettings: TimeSlotViewSettings(
//                       dayFormat: 'EEEE',
//                       dateFormat: 'dd',
//                       timeFormat: 'hh:mm a'),
//                   allowViewNavigation: false,
//                   headerHeight: 0,
//                   viewHeaderHeight: 0,
//                   cellBorderColor: const Color.fromRGBO(238, 243, 246, 1.0),
//                   selectionDecoration: BoxDecoration(
//                     color: Colors.transparent,
//                     border: Border.all(color: Colors.grey, width: 0.5),
//                     borderRadius: const BorderRadius.all(Radius.circular(4)),
//                     shape: BoxShape.rectangle,
//                   ),
//                   showWeekNumber: true,
//                   weekNumberStyle: WeekNumberStyle(
//                     backgroundColor: Colors.white,
//                     textStyle: TextStyle(fontSize: 8, color: Colors.grey[600]),
//                   ),
//                   monthViewSettings: MonthViewSettings(
//                     appointmentDisplayCount: 6,
//                     navigationDirection: MonthNavigationDirection.horizontal,
//                     showTrailingAndLeadingDates: false,
//                     monthCellStyle: MonthCellStyle(
//                       backgroundColor: Colors.white,
//                       todayBackgroundColor:
//                           const Color.fromRGBO(238, 243, 246, 1.0),
//                       textStyle: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                   ),
//                   allowAppointmentResize: true,
//                   allowDragAndDrop: true,
//                   //onDragStart: dragStart,
//                   //onDragUpdate: dragUpdate,
//                   // onDragEnd: dragEnd,
//                   dragAndDropSettings: const DragAndDropSettings(
//                     allowNavigation: true,
//                     allowScroll: true,
//                     autoNavigateDelay: Duration(seconds: 1),
//                     indicatorTimeFormat: 'HH:mm a',
//                     showTimeIndicator: true,
//                     timeIndicatorStyle: TextStyle(backgroundColor: Colors.grey),
//                   ),
//                   //showDatePickerButton: true,
//                   todayHighlightColor: Colors.grey[200],
//                   todayTextStyle: TextStyle(color: Colors.grey[800]),
//                   showNavigationArrow: true,
//                   showCurrentTimeIndicator: true,
//                   onViewChanged: (ViewChangedDetails viewChangedDetails) {
//                     if (_controller.view == CalendarView.month) {
//                       _headerText = DateFormat('yMMMM')
//                           .format(viewChangedDetails.visibleDates[
//                               viewChangedDetails.visibleDates.length ~/ 2])
//                           .toString();
//                     } else if (_controller.view == CalendarView.week) {
//                       _headerText = DateFormat('yMMMMd')
//                           .format(viewChangedDetails.visibleDates[
//                               viewChangedDetails.visibleDates.length ~/ 2])
//                           .toString();
//                     } else if (_controller.view == CalendarView.day) {
//                       _headerText = DateFormat('MMMMd')
//                           .format(viewChangedDetails.visibleDates[
//                               viewChangedDetails.visibleDates.length ~/ 2])
//                           .toString();
//                     }
//                     SchedulerBinding.instance.addPostFrameCallback((duration) {
//                       setState(() {});
//                     });
//                   },
//                   // onTap: (CalendarTapDetails calendarTapDetails) {
//                   //   showDialog(
//                   //     useSafeArea: true,
//                   //     context: context,
//                   //     builder: (BuildContext context) {
//                   //       return AlertDialog(
//                   //         title: const Text('New Event'),
//                   //         content: Mutation(
//                   //                       options: MutationOptions(
//                   //                         document: gql(insertEvent()),
//                   //                         fetchPolicy: FetchPolicy.noCache,
//                   //                         onCompleted: (data) {
//                   //                           print(data.toString());
//                   //                           setState(() {
//                   //                             //currUserId = (data as Map)['createUser']['id'];
//                   //                             //currUserId = data['createUser']["id"];
//                   //                           });
//                   //                         },
//                   //                       ),
//                   //                       builder: (runMutation, result) {
//                   //                         return Form(
//                   //                           key: _appForm,
//                   //                           child: SizedBox(
//                   //                             height: 500,
//                   //                             child: Column(
//                   //                               children: <Widget>[
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Subject',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 Row(
//                   //                                   mainAxisAlignment:
//                   //                                       MainAxisAlignment.spaceBetween,
//                   //                                   children: [
//                   //                                     SizedBox(
//                   //                                       height: 50,
//                   //                                       width: 100,
//                   //                                       child: TextFormField(
//                   //                                         autocorrect: true,
//                   //                                         controller:
//                   //                                             _eventStartDateController,
//                   //                                         style: Theme.of(context)
//                   //                                             .textTheme
//                   //                                             .bodyText1,
//                   //                                         decoration: const InputDecoration(
//                   //                                           labelText: 'Start Date',
//                   //                                           labelStyle:
//                   //                                               TextStyle(fontSize: 14),
//                   //                                           border: InputBorder.none,
//                   //                                           errorStyle: TextStyle(
//                   //                                               color: Colors.redAccent),
//                   //                                         ),
//                   //                                         textInputAction:
//                   //                                             TextInputAction.next,
//                   //                                         keyboardType:
//                   //                                             TextInputType.datetime,
//                   //                                         validator: (value) {
//                   //                                           if (value!.isEmpty) {
//                   //                                             return 'Please provide a value.';
//                   //                                           } else {
//                   //                                             return null;
//                   //                                           }
//                   //                                         },
//                   //                                       ),
//                   //                                     ),
//                   //                                     SizedBox(
//                   //                                       height: 50,
//                   //                                       width: 100,
//                   //                                       child: TextFormField(
//                   //                                         autocorrect: true,
//                   //                                         controller:
//                   //                                             _eventEndDateController,
//                   //                                         style: Theme.of(context)
//                   //                                             .textTheme
//                   //                                             .bodyText1,
//                   //                                         decoration: const InputDecoration(
//                   //                                           labelText: 'End Date',
//                   //                                           labelStyle:
//                   //                                               TextStyle(fontSize: 14),
//                   //                                           border: InputBorder.none,
//                   //                                           errorStyle: TextStyle(
//                   //                                               color: Colors.redAccent),
//                   //                                         ),
//                   //                                         textInputAction:
//                   //                                             TextInputAction.next,
//                   //                                         keyboardType:
//                   //                                             TextInputType.datetime,
//                   //                                         validator: (value) {
//                   //                                           if (value!.isEmpty) {
//                   //                                             return 'Please provide a value.';
//                   //                                           } else {
//                   //                                             return null;
//                   //                                           }
//                   //                                         },
//                   //                                       ),
//                   //                                     ),
//                   //                                   ],
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Category',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     //controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Description',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     //controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Calendars',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     //controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Attachements',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     //controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Organizier',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: TextFormField(
//                   //                                     autocorrect: true,
//                   //                                     //controller: _eventSubjController,
//                   //                                     style: Theme.of(context)
//                   //                                         .textTheme
//                   //                                         .bodyText1,
//                   //                                     maxLines: null,
//                   //                                     decoration: const InputDecoration(
//                   //                                       labelText: 'Attendees',
//                   //                                       labelStyle: TextStyle(fontSize: 14),
//                   //                                       border: InputBorder.none,
//                   //                                       errorStyle: TextStyle(
//                   //                                           color: Colors.redAccent),
//                   //                                     ),
//                   //                                     textInputAction: TextInputAction.next,
//                   //                                     keyboardType: TextInputType.name,
//                   //                                     validator: (value) {
//                   //                                       if (value!.isEmpty) {
//                   //                                         return 'Please provide a value.';
//                   //                                       } else {
//                   //                                         return null;
//                   //                                       }
//                   //                                     },
//                   //                                   ),
//                   //                                 ),
//                   //                                 // SizedBox(
//                   //                                 //   height: 50,
//                   //                                 //   width: 500,
//                   //                                 //   child: TextFormField(
//                   //                                 //     autocorrect: true,
//                   //                                 //     //controller: _eventSubjController,
//                   //                                 //     style:
//                   //                                 //         Theme.of(context).textTheme.bodyText1,
//                   //                                 //     maxLines: null,
//                   //                                 //     decoration: const InputDecoration(
//                   //                                 //       labelText: 'Repeat',
//                   //                                 //       labelStyle: TextStyle(fontSize: 14),
//                   //                                 //       border: InputBorder.none,
//                   //                                 //       errorStyle:
//                   //                                 //           TextStyle(color: Colors.redAccent),
//                   //                                 //     ),
//                   //                                 //     textInputAction: TextInputAction.next,
//                   //                                 //     keyboardType: TextInputType.name,
//                   //                                 //     validator: (value) {
//                   //                                 //       if (value!.isEmpty) {
//                   //                                 //         return 'Please provide a value.';
//                   //                                 //       } else {
//                   //                                 //         return null;
//                   //                                 //       }
//                   //                                 //     },
//                   //                                 //   ),
//                   //                                 // ),
//                   //                                 SizedBox(
//                   //                                   height: 50,
//                   //                                   width: 500,
//                   //                                   child: Row(
//                   //                                     mainAxisAlignment:
//                   //                                         MainAxisAlignment.spaceEvenly,
//                   //                                     children: [
//                   //                                       IconButton(
//                   //                                         onPressed: null,
//                   //                                         icon: Icon(
//                   //                                           Icons
//                   //                                               .notification_important_outlined,
//                   //                                           color: Colors.grey[800],
//                   //                                         ),
//                   //                                       ),
//                   //                                       IconButton(
//                   //                                         onPressed: null,
//                   //                                         icon: Icon(
//                   //                                           Icons.celebration,
//                   //                                           color: Colors.grey[800],
//                   //                                         ),
//                   //                                       ),
//                   //                                       IconButton(
//                   //                                         onPressed: null,
//                   //                                         icon: Icon(
//                   //                                           Icons.all_inclusive_outlined,
//                   //                                           color: Colors.grey[800],
//                   //                                         ),
//                   //                                       ),
//                   //                                       IconButton(
//                   //                                         onPressed: null,
//                   //                                         icon: Icon(
//                   //                                           Icons.task_outlined,
//                   //                                           color: Colors.grey[800],
//                   //                                         ),
//                   //                                       ),
//                   //                                       IconButton(
//                   //                                         onPressed: null,
//                   //                                         icon: Icon(
//                   //                                           Icons.schedule_outlined,
//                   //                                           color: Colors.grey[800],
//                   //                                         ),
//                   //                                       ),
//                   //                                     ],
//                   //                                   ),
//                   //                                 ),
//                   //                                 Row(
//                   //                                   mainAxisAlignment:
//                   //                                       MainAxisAlignment.end,
//                   //                                   children: [
//                   //                                     TextButton(
//                   //                                         child: const Text('Save'),
//                   //                                         onPressed: () {
//                   //                                           setState(() {
//                   //                                             runMutation({
//                   //                                               "event_subj":
//                   //                                                   _eventSubjController
//                   //                                                       .text
//                   //                                                       .trim(),
//                   //                                               "event_startdate":
//                   //                                                   _eventStartDateController
//                   //                                                       .text
//                   //                                                       .trim(),
//                   //                                               "event_enddate":
//                   //                                                   _eventEndDateController
//                   //                                                       .text
//                   //                                                       .trim(),
//                   //                                             });
//                   //                                             print("event mutation");
//                   //                                           });
//                   //                                           Navigator.of(context).pop();
//                   //                                         }),
//                   //                                     TextButton(
//                   //                                       onPressed: () {
//                   //                                         Navigator.of(context).pop();
//                   //                                       },
//                   //                                       child: const Text('Close'),
//                   //                                     )
//                   //                                   ],
//                   //                                 )
//                   //                               ],
//                   //                             ),
//                   //                           ),
//                   //                         );
//                   //                       },
//                   //                     ),
//                   //                   );
//                   //                 },
//                   //               );
//                   //             },
//                   //           );
//                   //         },
//                 ),
//               ),
//             ],
//           ),
//           //elevation: 5,
//         ],
//       ),
//     );
//   }

//   String insertEvent() {
//     return """
//       mutation createEvent(\$event_subj: String!, \$event_startdate: String, \$event_enddate: String, \$userId: String) {
//         createEvent(event_subj: \$event_subj, event_startdate: \$event_startdate, event_enddate: \$event_enddate, userId: \$userId) {
//           id
//           event_subj
          
//    }
// }
// """;
//   }
// }

// String _getEvents = """
//       query {
//         events{
//         event_subj
//         event_startdate
//         event_enddate
//   }
// }
// """;

// // MeetingDataSource _getCalendarDataSource([List<Meeting>? collection]) {
// //   List<Meeting> appointments = collection ?? <Meeting>[];
// //   return MeetingDataSource(appointments);
// // }

// // class MeetingDataSource extends CalendarDataSource<Meeting> {
// //   MeetingDataSource(List<Meeting> events) {
// //     appointments = events;
// //   }

// //   @override
// //   DateTime getStartTime(int index) {
// //     return "${["event_startdate"]}" as DateTime;
// //     //appointments![index].from as DateTime;
// //   }

// //   @override
// //   DateTime getEndTime(int index) {
// //     return "${["event_enddate"]}" as DateTime;
// //     //appointments![index].to as DateTime;
// //   }

// //   @override
// //   String getSubject(int index) {
// //     return "${["event_subj"]}";
// //     //appointments![index].content as String;
// //   }
// //   // @override
// //   // Color getColor(int index) {
// //   //   return appointments![index].background as Color;
// //   // }

// //   // @override
// //   // bool isAllDay(int index) {
// //   //   return appointments![index].isAllDay;
// //   // }
// // }

// // MeetingDataSource _getCalendarDataSource() {
// //   List<Meeting> appointments = <Meeting>[];
// //   appointments.add(Meeting(
// //     from: "${["event_startdate"]}" as DateTime,
// //     to: "${["event_enddate"]}" as DateTime,
// //     eventName: "${["event_subj"]}",
// //     // isAllDay: false,
// //     // background: Colors.red,
// //     // fromZone: '',
// //     // toZone: '',
// //     // recurrenceRule: '',
// //     // exceptionDates: null
// //   ));

// //   return MeetingDataSource(appointments);
// // }

// void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
//   dynamic appointment = appointmentDragStartDetails.appointment;
//   CalendarResource? resource = appointmentDragStartDetails.resource;
// }

// // void dragUpdate(AppointmentDragUpdateDetails appointmentDragUpdateDetails) {
// //   dynamic appointment = appointmentDragUpdateDetails.appointment;
// //   DateTime? draggingTime = appointmentDragUpdateDetails.draggingTime;
// //   Offset? draggingOffset = appointmentDragUpdateDetails.draggingPosition;
// //   CalendarResource? sourceResource =
// //       appointmentDragUpdateDetails.sourceResource;
// //   CalendarResource? targetResource =
// //       appointmentDragUpdateDetails.targetResource;
// // }

// // void calendarTapped(CalendarTapDetails calendarTapDetails) {
// //   var context;
// //   showDialog(
// //     useSafeArea: true,
// //     context: context,
// //     builder: (BuildContext context) {
// //       var _appForm;
// //       var _eventSubjController;
// //       return AlertDialog(
// //         title: const Text('New Appointment'),
// //         content: Form(
// //           key: _appForm,
// //           child: SizedBox(
// //             height: 500,
// //             child: Column(
// //               children: <Widget>[
// //                 SizedBox(
// //                   height: 100,
// //                   width: 100,
// //                   child: TextFormField(
// //                     autocorrect: true,
// //                     controller: _eventSubjController,
// //                     style: Theme.of(context).textTheme.bodyText1,
// //                     maxLines: null,
// //                     decoration: const InputDecoration(
// //                       labelText: 'Subject',
// //                       labelStyle: TextStyle(fontSize: 14),
// //                       border: InputBorder.none,
// //                       errorStyle: TextStyle(color: Colors.redAccent),
// //                     ),
// //                     textInputAction: TextInputAction.next,
// //                     keyboardType: TextInputType.name,
// //                     validator: (value) {
// //                       if (value!.isEmpty) {
// //                         return 'Please provide a value.';
// //                       } else {
// //                         return null;
// //                       }
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         actions: <Widget>[
// //           TextButton(
// //             onPressed: () {
// //               Navigator.of(context).pop();
// //             },
// //             child: const Text('Save'),
// //           ),
// //           TextButton(
// //             onPressed: () {
// //               Navigator.of(context).pop();
// //             },
// //             child: const Text('Close'),
// //           )
// //         ],
// //       );
// //     },
// //   );
// // }
