// import 'package:flutter/material.dart';

// class TaskListDWidget extends StatefulWidget {
//   //TaskListWidget({Key? key}) : super(key: key);

//   @override
//   State<TaskListDWidget> createState() => _TaskListWidgetDState();
// }

// class _TaskListWidgetDState extends State<TaskListDWidget> {
//   List tasks = [];

//   // void _deleteTask(String id) {
//   //   setState(() {
//   //     tasks.removeWhere((tasks) => tasks.id == id);
//   //   });
//   // }

//   // void _startAddNewTask(BuildContext mctx) {
//   //   showModalBottomSheet(
//   //     context: mctx,
//   //     builder: (_) {
//   //       return GestureDetector(
//   //         onTap: () {},
//   //         behavior: HitTestBehavior.opaque,
//   //         child: NewTask(addNewTask),
//   //       );
//   //     },
//   //   );
//   // }

//   // addNewTask(String taskTitle, String taskCategory, Color catColor) {
//   //   final newTask = Task(
//   //     title: taskTitle,
//   //     id: DateTime.now().toString(),
//   //     category: taskCategory,
//   //     catColor: catColor,
//   //     dateCreated: DateTime.now(),
//   //     dateChanged: DateTime.now(),
//   //     userId: DateTime.now().toString(),
//   //   );

//   //   setState(() {
//   //     tasks.add(newTask);
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final isLandscape = mediaQuery.orientation == Orientation.landscape;
//     return Container(
//       child: LayoutBuilder(
//         builder: (ctx, constraints) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               !isLandscape
//                   ? SizedBox(
//                       height: constraints.maxHeight * 0.95,
//                       child:
//                           //        Query(
//                           //           options: QueryOptions(
//                           //             document: gql(_getTasks),
//                           //             cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
//                           //             pollInterval: const Duration(seconds: 5),
//                           //             fetchPolicy: FetchPolicy.cacheAndNetwork,
//                           //           ),
//                           //           builder: (QueryResult result,
//                           //               {VoidCallback? refetch, FetchMore? fetchMore}) {
//                           //             if (result.hasException) {
//                           //               return Text(result.exception.toString());
//                           //             }
//                           //             if (result.isLoading) {
//                           //               return const CircularProgressIndicator();
//                           //             }
//                           //             tasks = result.data!["tasks"];
//                           //             return
//                           ReorderableListView.builder(
//                         onReorder: (oldIndex, newIndex) {
//                           setState(() {
//                             if (oldIndex < newIndex) {
//                               newIndex -= 1;
//                             }
//                             final task = tasks.removeAt(oldIndex);
//                             tasks.insert(newIndex, task);
//                           });
//                         },
//                         scrollDirection: Axis.vertical,
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: tasks.length,
//                         itemBuilder: (ctx, index) {
//                           final task = tasks[index];
//                           return Dismissible(
//                             // ignore: sort_child_properties_last
//                             child: Card(child: Text('Dummy Card')),

//                             // TaskItem(
//                             //   "${task["id"]}",
//                             //   "${task["task_description"]}",
//                             //   "${task["category"]}",
//                             //   //_deleteTask,
//                             //   //"${task['user']["id"]}",
//                             // ),
//                             key: ValueKey(tasks[index]),
//                             background: Container(
//                               color: Colors.orangeAccent,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5),
//                                 child: Row(
//                                   children: const [
//                                     Text(
//                                       'Done',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             secondaryBackground: Container(
//                               color: Colors.redAccent,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: const [
//                                     Text(
//                                       'Delete',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             onDismissed: (DismissDirection direction) {
//                               if (direction == DismissDirection.startToEnd) {
//                                 print("Done");
//                                 setState(() {
//                                   tasks.removeAt(index);
//                                 });
//                               } else {
//                                 print('Remove item');
//                                 setState(() {
//                                   tasks.removeAt(index);
//                                 });
//                               }
//                             },
//                             confirmDismiss: (DismissDirection direction) async {
//                               if (direction == DismissDirection.startToEnd) {
//                                 showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         title: const Text("Well Done"),
//                                         //             .pop(false),
//                                         //content: const Text("Well Done!"),
//                                         // actions: <Widget>[
//                                         //   TextButton(
//                                         //     onPressed: () =>
//                                         //         Navigator.of(context)
//                                         //             .pop(false),
//                                         //     child: const Text("Done"),
//                                         //   ),
//                                         // ],
//                                       );
//                                     });
//                               } else {
//                                 return await showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return
//                                         // Mutation(
//                                         //   options: MutationOptions(
//                                         //     document: gql(_removeTask()),
//                                         //     onCompleted: (data) {},
//                                         //   ),
//                                         //   builder: (runMutation, result) {
//                                         //     return
//                                         AlertDialog(
//                                       title: const Text("Delete Confirmation"),
//                                       content: const Text(
//                                           "Are you sure you want to delete this item?"),
//                                       actions: <Widget>[
//                                         TextButton(
//                                             onPressed: () async {
//                                               // runMutation(
//                                               //     {"id": task["id"]});
//                                               Navigator.of(context).pop(true);
//                                             },
//                                             child: const Text("Delete")),
//                                         TextButton(
//                                           onPressed: () =>
//                                               Navigator.of(context).pop(false),
//                                           child: const Text("Cancel"),
//                                         ),
//                                       ],
//                                       //     );
//                                       //   },
//                                     );
//                                   },
//                                 );
//                               }
//                               ;
//                             },
//                           );
//                         },
//                       ),
//                     )
//                   //     },
//                   //   ),
//                   // )
//                   : SizedBox(
//                       height: constraints.maxHeight * 0.8,
//                       child: Card(
//                         child: Text('Dummy Card'),
//                       ),
//                       //TasksList()
//                       // ListView.builder(
//                       //   scrollDirection: Axis.vertical,
//                       //   physics: const AlwaysScrollableScrollPhysics(),
//                       //   itemCount: tasks.length,
//                       //   itemBuilder: (ctx, index) => ChangeNotifierProvider.value( {

//                       //   },
//                       //   value: tasks[index],
//                       //    child: TaskItem(
//                       //       tasks[index].id,
//                       //       tasks[index].title,
//                       //       tasks[index].category,
//                       //       _deleteTask,
//                       //       //editTask,
//                       //       //tasks[index].catColor,
//                       //       //tasks[index].userId,
//                       //     ), ),
//                       //     )
//                     ),
//               // !isLandscape
//               //     ? SizedBox(
//               //         height: constraints.maxHeight * 0.05,
//               //         child: TextButton(
//               //           child: Text(
//               //             '+ Add new',
//               //             style: Theme.of(context).textTheme.headline2,
//               //           ),
//               //           onPressed: () => _startAddNewTask(context),
//               //         ),
//               //       )
//               //     : SizedBox(
//               //         height: constraints.maxHeight * 0.05,
//               //         child: TextButton(
//               //           child: Text(
//               //             '+ Add new',
//               //             style: Theme.of(context).textTheme.headline2,
//               //           ),
//               //           onPressed: () => _startAddNewTask(context),
//               //         ),
//               //         )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // String _getTasks = """
// // query {
// //   tasks{
// //     id
// //     task_description
// //     category
// //     user{
// //       id
// //     }
// //   }
// // }
// // """;

// // String _removeTask() {
// //   return """
// //   mutation removeTask(\$id: String!){
// //     removeTask(id: \$id) {
// //       task_description
// //     }
// //   }
// //   """;
// //}
