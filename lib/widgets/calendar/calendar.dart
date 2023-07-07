import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
//import 'package:timelyst_flutter/widgets/calendar/traffic_light.dart';
import 'package:timelyst_flutter/widgets/calendar/week_days.dart';

import 'event_of_day.dart';

//Enable when connecting actual data source via actual model
//import '../../models/event.dart';

enum _calView { day, week, month }

class CalendarW extends StatefulWidget {
  const CalendarW({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CalendarWState();
}

class _CalendarWState extends State<CalendarW> {
  final _appForm = GlobalKey<FormState>();
  final _eventSubjController = TextEditingController();
  //final _eventSourceController = TextEditingController();
  final _eventStartDateController = TextEditingController();
  final _eventEndDateController = TextEditingController();

  CalendarController _controller = CalendarController();
  String? _headerText;

  @override
  void initState() {
    _controller = CalendarController();
    _headerText = '';

    // _getEvents().then((results) {
    //   setState(() {
    //     if (results != null) {
    //       querySnapshot = results;
    //     }
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = MediaQuery.of(context).size.width;
    final cellWidth = width / 16;
    final isMonth = _controller.view == CalendarView.month;
    final isWeek = _controller.view == CalendarView.week;

    return Card(
      child: Column(
        children: [
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Enable once traffic light logic is implemented
                // const Padding(
                //   padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                //   child: TrafficLightW(),
                // ),
                SizedBox(
                  width: mediaQuery.size.width * 0.38,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20),
                    child: Text(
                      _headerText!,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                //Use back and forward controllers for the web version
                // Padding(
                //   padding: const EdgeInsets.only(left: 4, right: 4),
                //   child: SizedBox(
                //     width: mediaQuery.size.width * 0.025,
                //     child: IconButton(
                //       iconSize: 18,
                //       color: Colors.grey[800],
                //       icon: const Icon(Icons.arrow_back),
                //       onPressed: () {
                //         //_controller.backward!();
                //       },
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 6, right: 4),
                //   child: SizedBox(
                //     width: mediaQuery.size.width * 0.025,
                //     child: IconButton(
                //       iconSize: 18,
                //       color: Colors.grey[800],
                //       icon: const Icon(Icons.arrow_forward),
                //       onPressed: () {
                //         //_controller.forward!();
                //       },
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 10),
                  child: SizedBox(
                    //width: mediaQuery.size.width * 0.03,
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[800],
                      ),
                      iconSize: 20,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<_calView>>[
                        const PopupMenuItem<_calView>(
                          value: _calView.day,
                          child: Text('Day'),
                        ),
                        const PopupMenuItem<_calView>(
                          value: _calView.week,
                          child: Text('Week'),
                        ),
                        const PopupMenuItem<_calView>(
                          value: _calView.month,
                          child: Text('Month'),
                        ),
                      ],
                      onSelected: (value) {
                        setState(
                          () {
                            if (value == _calView.day) {
                              _controller.view = CalendarView.day;
                            } else if (value == _calView.week) {
                              _controller.view = CalendarView.week;
                            } else if (value == _calView.month) {
                              _controller.view = CalendarView.month;
                            }
                            ;
                          },
                        );
                      },
                    ),
                    //},
                  ),
                ),
                //),
              ],
            ),
            Container(
              width: width,
              color: const Color.fromRGBO(238, 243, 246, 1.0),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: EventOfDayW(),
              ),
            ),
            isMonth
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: WeekDaysW(
                        cellWidth: cellWidth,
                        viewHeaderText6: 'Sun',
                        viewHeaderText: 'Mon',
                        viewHeaderText1: 'Tue',
                        viewHeaderText2: 'Wed',
                        viewHeaderText3: 'Thu',
                        viewHeaderText4: 'Fri',
                        viewHeaderText5: 'Sat'),
                  )
                : isWeek
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: WeekDaysW(
                            cellWidth: 7,
                            viewHeaderText6: 'S',
                            viewHeaderText: 'M',
                            viewHeaderText1: 'T',
                            viewHeaderText2: 'W',
                            viewHeaderText3: 'T',
                            viewHeaderText4: 'F',
                            viewHeaderText5: 'S'),
                      )
                    : Container(),
          ]),

          //],
          //),

          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              allowedViews: const [
                CalendarView.week,
                CalendarView.day,
                CalendarView.month
              ],
              controller: _controller,
              dataSource: EventDataSource(_getDataSource()),
              timeSlotViewSettings: TimeSlotViewSettings(
                  dayFormat: 'EEEE', dateFormat: 'dd', timeFormat: 'hh:mm a'),
              allowViewNavigation: false,
              headerHeight: 0,
              viewHeaderHeight: 0,
              cellBorderColor: const Color.fromRGBO(238, 243, 246, 1.0),
              selectionDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                shape: BoxShape.rectangle,
              ),
              showWeekNumber: true,
              weekNumberStyle: WeekNumberStyle(
                backgroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayCount: 6,
                navigationDirection: MonthNavigationDirection.horizontal,
                showTrailingAndLeadingDates: false,
                monthCellStyle: MonthCellStyle(
                  backgroundColor: Colors.white,
                  todayBackgroundColor:
                      const Color.fromRGBO(238, 243, 246, 1.0),
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              onViewChanged: (ViewChangedDetails viewChangedDetails) {
                if (_controller.view == CalendarView.month) {
                  _headerText = DateFormat('MMMMd')
                      .format(viewChangedDetails.visibleDates[
                          viewChangedDetails.visibleDates.length ~/ 2])
                      .toString();
                } else if (_controller.view == CalendarView.week) {
                  _headerText = DateFormat('MMMMd')
                      .format(viewChangedDetails.visibleDates[
                          viewChangedDetails.visibleDates.length ~/ 2])
                      .toString();
                } else if (_controller.view == CalendarView.day) {
                  _headerText = DateFormat('MMMMd')
                      .format(viewChangedDetails.visibleDates[
                          viewChangedDetails.visibleDates.length ~/ 2])
                      .toString();
                }
              },
              allowAppointmentResize: true,
              allowDragAndDrop: true,
              //onDragStart: dragStart,
              //onDragUpdate: dragUpdate,
              // onDragEnd: dragEnd,
              dragAndDropSettings: const DragAndDropSettings(
                allowNavigation: true,
                allowScroll: true,
                autoNavigateDelay: Duration(seconds: 1),
                indicatorTimeFormat: 'HH:mm a',
                showTimeIndicator: true,
                timeIndicatorStyle: TextStyle(backgroundColor: Colors.grey),
              ),
              //showDatePickerButton: true,
              todayHighlightColor: Colors.grey[200],
              todayTextStyle: TextStyle(color: Colors.grey[800]),
              showNavigationArrow: true,
              showCurrentTimeIndicator: true,
              onTap: (CalendarTapDetails calendarTapDetails) async {
                showDialog(
                  useSafeArea: true,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('New Event'),
                      content:
                          //  Mutation(
                          //               options: MutationOptions(
                          //                 document: gql(insertEvent()),
                          //                 fetchPolicy: FetchPolicy.noCache,
                          //                 onCompleted: (data) {
                          //                   print(data.toString());
                          //                   setState(() {
                          //                     //currUserId = (data as Map)['createUser']['id'];
                          //                     //currUserId = data['createUser']["id"];
                          //                   });
                          //                 },
                          //               ),
                          //               builder: (runMutation, result) {
                          //                 return
                          Form(
                        key: _appForm,
                        child: SizedBox(
                          height: 500,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Subject',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 100,
                                    child: TextFormField(
                                      autocorrect: true,
                                      controller: _eventStartDateController,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      decoration: const InputDecoration(
                                        labelText: 'Start Date',
                                        labelStyle: TextStyle(fontSize: 14),
                                        border: InputBorder.none,
                                        errorStyle:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.datetime,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please provide a value.';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 100,
                                    child: TextFormField(
                                      autocorrect: true,
                                      controller: _eventEndDateController,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      decoration: const InputDecoration(
                                        labelText: 'End Date',
                                        labelStyle: TextStyle(fontSize: 14),
                                        border: InputBorder.none,
                                        errorStyle:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.datetime,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please provide a value.';
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  //controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Calendars',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Attachements',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Organizier',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: TextFormField(
                                  autocorrect: true,
                                  controller: _eventSubjController,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: 'Attendees',
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    errorStyle:
                                        TextStyle(color: Colors.redAccent),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please provide a value.';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              // SizedBox(
                              //   height: 50,
                              //   width: 500,
                              //   child: TextFormField(
                              //     autocorrect: true,
                              //     //controller: _eventSubjController,
                              //     style:
                              //         Theme.of(context).textTheme.bodyText1,
                              //     maxLines: null,
                              //     decoration: const InputDecoration(
                              //       labelText: 'Repeat',
                              //       labelStyle: TextStyle(fontSize: 14),
                              //       border: InputBorder.none,
                              //       errorStyle:
                              //           TextStyle(color: Colors.redAccent),
                              //     ),
                              //     textInputAction: TextInputAction.next,
                              //     keyboardType: TextInputType.name,
                              //     validator: (value) {
                              //       if (value!.isEmpty) {
                              //         return 'Please provide a value.';
                              //       } else {
                              //         return null;
                              //       }
                              //     },
                              //   ),
                              // ),
                              SizedBox(
                                height: 50,
                                width: 500,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.notification_important_outlined,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.celebration,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.all_inclusive_outlined,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.task_outlined,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.schedule_outlined,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      child: const Text('Save'),
                                      onPressed: () {
                                        setState(() {
                                          // runMutation({
                                          //   "event_subj":
                                          //       _eventSubjController
                                          //           .text
                                          //           .trim(),
                                          //   "event_startdate":
                                          //       _eventStartDateController
                                          //           .text
                                          //           .trim(),
                                          //   "event_enddate":
                                          //       _eventEndDateController
                                          //           .text
                                          //           .trim(),
                                          // });
                                          print("event mutation");
                                        });
                                        Navigator.of(context).pop();
                                      }),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

List<Event> _getDataSource() {
  final List<Event> events = <Event>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));
  events.add(
      Event('Conference', startTime, endTime, const Color(0xFF0F8644), false));
  return events;
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

//the code should be replaced witht the actual model
class Event {
  Event(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

//uncomment once App wide State (InitState is fixed to provide the Calendar details)
// void calendarTapped(CalendarTapDetails details) {
//   final _appForm = GlobalKey<FormState>();
//   final _eventSubjController = TextEditingController();
//   final _eventStartDateController = TextEditingController();
//   final _eventEndDateController = TextEditingController();
//   var context;
//   showDialog(
//       useSafeArea: true,
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('New Event'),
//           content:
//               //  Mutation(
//               //               options: MutationOptions(
//               //                 document: gql(insertEvent()),
//               //                 fetchPolicy: FetchPolicy.noCache,
//               //                 onCompleted: (data) {
//               //                   print(data.toString());
//               //                   setState(() {
//               //                     //currUserId = (data as Map)['createUser']['id'];
//               //                     //currUserId = data['createUser']["id"];
//               //                   });
//               //                 },
//               //               ),
//               //               builder: (runMutation, result) {
//               //                 return
//               Form(
//             key: _appForm,
//             child: SizedBox(
//               height: 500,
//               child: Column(
//                 children: <Widget>[
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Subject',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         height: 50,
//                         width: 100,
//                         child: TextFormField(
//                           autocorrect: true,
//                           controller: _eventStartDateController,
//                           style: Theme.of(context).textTheme.bodyLarge,
//                           decoration: const InputDecoration(
//                             labelText: 'Start Date',
//                             labelStyle: TextStyle(fontSize: 14),
//                             border: InputBorder.none,
//                             errorStyle: TextStyle(color: Colors.redAccent),
//                           ),
//                           textInputAction: TextInputAction.next,
//                           keyboardType: TextInputType.datetime,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please provide a value.';
//                             } else {
//                               return null;
//                             }
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         height: 50,
//                         width: 100,
//                         child: TextFormField(
//                           autocorrect: true,
//                           controller: _eventEndDateController,
//                           style: Theme.of(context).textTheme.bodyLarge,
//                           decoration: const InputDecoration(
//                             labelText: 'End Date',
//                             labelStyle: TextStyle(fontSize: 14),
//                             border: InputBorder.none,
//                             errorStyle: TextStyle(color: Colors.redAccent),
//                           ),
//                           textInputAction: TextInputAction.next,
//                           keyboardType: TextInputType.datetime,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please provide a value.';
//                             } else {
//                               return null;
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Category',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       //controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Calendars',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Attachements',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Organizier',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: TextFormField(
//                       autocorrect: true,
//                       controller: _eventSubjController,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         labelText: 'Attendees',
//                         labelStyle: TextStyle(fontSize: 14),
//                         border: InputBorder.none,
//                         errorStyle: TextStyle(color: Colors.redAccent),
//                       ),
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.name,
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please provide a value.';
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   // SizedBox(
//                   //   height: 50,
//                   //   width: 500,
//                   //   child: TextFormField(
//                   //     autocorrect: true,
//                   //     //controller: _eventSubjController,
//                   //     style:
//                   //         Theme.of(context).textTheme.bodyText1,
//                   //     maxLines: null,
//                   //     decoration: const InputDecoration(
//                   //       labelText: 'Repeat',
//                   //       labelStyle: TextStyle(fontSize: 14),
//                   //       border: InputBorder.none,
//                   //       errorStyle:
//                   //           TextStyle(color: Colors.redAccent),
//                   //     ),
//                   //     textInputAction: TextInputAction.next,
//                   //     keyboardType: TextInputType.name,
//                   //     validator: (value) {
//                   //       if (value!.isEmpty) {
//                   //         return 'Please provide a value.';
//                   //       } else {
//                   //         return null;
//                   //       }
//                   //     },
//                   //   ),
//                   // ),
//                   SizedBox(
//                     height: 50,
//                     width: 500,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         IconButton(
//                           onPressed: null,
//                           icon: Icon(
//                             Icons.notification_important_outlined,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: null,
//                           icon: Icon(
//                             Icons.celebration,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: null,
//                           icon: Icon(
//                             Icons.all_inclusive_outlined,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: null,
//                           icon: Icon(
//                             Icons.task_outlined,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: null,
//                           icon: Icon(
//                             Icons.schedule_outlined,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                           child: const Text('Save'),
//                           onPressed: () {
//                             // setState(() {
//                             //   // runMutation({
//                             //   //   "event_subj":
//                             //   //       _eventSubjController
//                             //   //           .text
//                             //   //           .trim(),
//                             //   //   "event_startdate":
//                             //   //       _eventStartDateController
//                             //   //           .text
//                             //   //           .trim(),
//                             //   //   "event_enddate":
//                             //   //       _eventEndDateController
//                             //   //           .text
//                             //   //           .trim(),
//                             //   // });
//                             //   print("event mutation");
//                             // });
//                             Navigator.of(context).pop();
//                           }),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text('Close'),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       });
// }
