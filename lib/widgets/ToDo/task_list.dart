import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../widgets/ToDo/task_item.dart';

class TaskListW extends StatefulWidget {
  @override
  _TaskListWState createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      _fetchTasks();
    }
  }

  void _fetchTasks() {
    print("Entered _fetchTasks in task_list");
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authService = AuthService();
        final authToken = await authService.getAuthToken();
        final userId = await authService.getUserId();
        print("User ID: $userId");
        if (authToken != null && userId != null) {
          taskProvider.fetchTasks(userId, authToken);
        }
        // final storage = FlutterSecureStorage();
        // storage.read(key: 'authToken').then((authToken) {
        //   storage.read(key: 'userId').then((userId) {
        //     print("User ID: $userId");
        //     if (authToken != null && userId != null) {
        //       taskProvider.fetchTasks(userId, authToken);
        //     }
        //   });
        // });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Loading state
    if (taskProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Error state
    if (taskProvider.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.vertical,
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (ctx, index) {
                    final task = taskProvider.tasks[index];
                    return ReorderableDragStartListener(
                      key: Key(task.id),
                      index: index,
                      child: Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.horizontal,
                        child: TaskItem(
                          id: task.id,
                          title: task.title,
                          category: task.category,
                          status: task.status,
                          onTaskUpdated: (updatedTask) {
                            taskProvider.updateTask("updatedTask", "", "", "");
                          },
                        ),
                        onDismissed: (DismissDirection direction) async {
                          final storage = FlutterSecureStorage();
                          final authToken =
                              await storage.read(key: 'authToken');

                          if (direction == DismissDirection.startToEnd) {
                            await taskProvider.markTaskAsComplete(
                                task.id, authToken!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.shadow,
                                content: Text(
                                  'Well Done!',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          } else {
                            await taskProvider.deleteTask(task.id, authToken!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.shadow,
                                content: Text(
                                  'Task deleted',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        },
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            return true;
                          } else {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Confirmation",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete this item?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        "Delete",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        background: Container(
                          color: Colors.greenAccent[100],
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Text(
                                  'Done',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.orangeAccent[100],
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Delete',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    taskProvider.reorderTasks(oldIndex, newIndex);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
// import 'package:timelyst_flutter/providers/taskProvider.dart';
// import '../../widgets/ToDo/task_item.dart';

// class TaskListW extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final taskProvider = Provider.of<TaskProvider>(context);

//     // Fetch tasks on initial load
//     if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final storage = FlutterSecureStorage();
//         storage.read(key: 'authToken').then((authToken) {
//           storage.read(key: 'userId').then((userId) {
//             if (authToken != null && userId != null) {
//               taskProvider.fetchTasks(userId, authToken);
//             }
//           });
//         });
//       });
//     }

//     // Loading state
//     if (taskProvider.isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     // Error state
//     if (taskProvider.errorMessage.isNotEmpty) {
//       return Center(child: Text('Error: ${taskProvider.errorMessage}'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Task List'),
//       ),
//       body: LayoutBuilder(
//         builder: (ctx, constraints) {
//           return Column(
//             children: [
//               Expanded(
//                 child: ReorderableListView.builder(
//                   buildDefaultDragHandles: false,
//                   scrollDirection: Axis.vertical,
//                   itemCount: taskProvider.tasks.length,
//                   itemBuilder: (ctx, index) {
//                     final task = taskProvider.tasks[index];
//                     return ReorderableDragStartListener(
//                       key: Key(task.id),
//                       index: index,
//                       child: Dismissible(
//                         key: Key(task.id),
//                         direction: DismissDirection.horizontal,
//                         child: TaskItem(
//                           id: task.id,
//                           title: task.title,
//                           category: task.category,
//                           status: task.status,
//                           onTaskUpdated: (updatedTask) {
//                             taskProvider.updateTask("updatedTask", "", "", "");
//                           }, // Pass the status to TaskItem
//                         ),
//                         onDismissed: (DismissDirection direction) async {
//                           final storage = FlutterSecureStorage();
//                           final authToken =
//                               await storage.read(key: 'authToken');

//                           if (direction == DismissDirection.startToEnd) {
//                             // Mark task as complete
//                             await taskProvider.markTaskAsComplete(
//                                 task.id, authToken!);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor:
//                                     Theme.of(context).colorScheme.shadow,
//                                 content: Text(
//                                   'Well Done!',
//                                   style: Theme.of(context).textTheme.bodyLarge,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             // Delete task
//                             await taskProvider.deleteTask(task.id, authToken!);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor:
//                                     Theme.of(context).colorScheme.shadow,
//                                 content: Text(
//                                   'Task deleted',
//                                   style: Theme.of(context).textTheme.bodyLarge,
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         confirmDismiss: (DismissDirection direction) async {
//                           if (direction == DismissDirection.startToEnd) {
//                             return true;
//                           } else {
//                             return await showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: Text(
//                                     "Confirmation",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .displaySmall,
//                                   ),
//                                   content: Text(
//                                     "Are you sure you want to delete this item?",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .displayMedium,
//                                   ),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       style: TextButton.styleFrom(
//                                         backgroundColor: Theme.of(context)
//                                             .colorScheme
//                                             .shadow,
//                                       ),
//                                       onPressed: () =>
//                                           Navigator.of(context).pop(false),
//                                       child: Text(
//                                         "Cancel",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyLarge,
//                                       ),
//                                     ),
//                                     TextButton(
//                                       style: TextButton.styleFrom(
//                                         backgroundColor: Theme.of(context)
//                                             .colorScheme
//                                             .shadow,
//                                       ),
//                                       onPressed: () =>
//                                           Navigator.of(context).pop(true),
//                                       child: Text(
//                                         "Delete",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyLarge,
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           }
//                         },
//                         background: Container(
//                           color: Colors.greenAccent[100],
//                           child: Padding(
//                             padding: const EdgeInsets.all(5),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Done',
//                                   style: Theme.of(context).textTheme.bodyLarge,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         secondaryBackground: Container(
//                           color: Colors.orangeAccent[100],
//                           child: Padding(
//                             padding: const EdgeInsets.all(5),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   'Delete',
//                                   style: Theme.of(context).textTheme.bodyLarge,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   onReorder: (oldIndex, newIndex) {
//                     taskProvider.reorderTasks(oldIndex, newIndex);
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// task_list.dart
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../data/tasks.dart';
// import '../../models/task.dart';
// import 'task_item.dart';

// class TaskListW extends StatefulWidget {
//   @override
//   State<TaskListW> createState() => _TaskListWState();
// }

// class _TaskListWState extends State<TaskListW> {
//   List<Task> _tasks = [];
//   final storage = FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();
//     _fetchTasks();
//   }

//   Future<void> _fetchTasks() async {
//     try {
//       final authToken = await storage.read(key: 'authToken');
//       final userId = await storage.read(key: 'userId');
//       final tasks = await TasksService.fetchUserTasks(userId!, authToken!);
//       setState(() {
//         _tasks = tasks;
//       });
//     } on SocketException {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No internet connection')),
//       );
//     } on HttpException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to fetch tasks: ${e.message}')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An unexpected error occurred: $e')),
//       );
//     }
//   }

//   void _onTaskUpdated(Task updatedTask) {
//     setState(() {
//       final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
//       if (index != -1) {
//         _tasks[index] = updatedTask;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: _tasks.length,
//       itemBuilder: (ctx, index) {
//         final task = _tasks[index];
//         return TaskItem(
//           id: task.id,
//           title: task.title,
//           category: task.category,
//           onTaskUpdated: _onTaskUpdated,
//         );
//       },
//     );
//   }
// }


// class TaskListW extends StatefulWidget {
//   TaskListW({Key? key}) : super(key: key);

//   @override
//   State<TaskListW> createState() => _TaskListWState();
// }

// class _TaskListWState extends State<TaskListW> {
//   //Dummy tasks - remove once connected to database
//   // List _dummyTasks = [
//   //   Task(
//   //     id: '1234',
//   //     title: 'Try Me',
//   //     category: 'Personal',
//   //     dateCreated: DateTime.now().subtract(Duration(days: 2)),
//   //     dateChanged: DateTime.now(),
//   //     creator: 'Maria Donosova',
//   //   ),
//   //   Task(
//   //     id: '21234',
//   //     title: 'Dare',
//   //     category: 'Work',
//   //     dateCreated: DateTime.now().subtract(Duration(days: 1)),
//   //     dateChanged: DateTime.now(),
//   //     creator: 'Maria Donosova',
//   //   ),
//   //   Task(
//   //     id: '35467',
//   //     title: 'Destiny',
//   //     category: 'Friends',
//   //     dateCreated: DateTime.now().subtract(Duration(days: 3)),
//   //     dateChanged: DateTime.now(),
//   //     creator: 'Maria Donosova',
//   //   ),
//   //   Task(
//   //     id: '4567',
//   //     title: 'Work it out',
//   //     category: 'Other',
//   //     dateCreated: DateTime.now().subtract(Duration(days: 10)),
//   //     dateChanged: DateTime.now(),
//   //     creator: 'Maria Donosova',
//   //   ),
//   //   Task(
//   //     id: '5124',
//   //     title: 'Just do it',
//   //     category: 'Family',
//   //     dateCreated: DateTime.now().subtract(Duration(days: 7)),
//   //     dateChanged: DateTime.now(),
//   //     creator: 'Maria Donosova',
//   //   ),
//   // ];

//   List<Task> _tasks = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchTasks();
//   }

//   Future<void> _fetchTasks() async {
//     try {
//       final tasks = await TasksService.fetchUserTasks('userId', 'authToken');
//       setState(() {
//         _tasks = tasks;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   //Reodering for reoderable list logic
//   void _onReorder(int oldIndex, int newIndex) {
//     if (oldIndex < newIndex) {
//       newIndex -= 1;
//     }
//     final item = _tasks.removeAt(oldIndex);
//     _tasks.insert(newIndex, item);
//     setState(() {});
//   }

//   void _onDismissed(index) {
//     _tasks.removeAt(index);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final mediaQuery = MediaQuery.of(context);

//     // Loading
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(child: Text('Error: $_errorMessage'));
//     }

//     return LayoutBuilder(
//       builder: (ctx, constraints) {
//         return Column(children: [
//           Expanded(
//             flex: 1,
//             child: ReorderableListView.builder(
//               buildDefaultDragHandles: false,
//               scrollDirection: Axis.vertical,
//               itemCount: _tasks.length,
//               itemBuilder: (ctx, index) {
//                 final item = _tasks[index];
//                 return ReorderableDragStartListener(
//                   key: Key(item.id),
//                   index: index,
//                   child: Dismissible(
//                     key: Key(item.id),
//                     direction: DismissDirection.horizontal,
//                     child: TaskItem(
//                       _tasks[index].id,
//                       _tasks[index].title,
//                       _tasks[index].category,

//                       //"${task["id"]}",
//                       // "${task["task_description"]}",
//                       // "${task["category"]}",
//                       // _deleteTask,
//                       // "${task['user']["id"]}",
//                     ),
//                     onDismissed: (DismissDirection direction) {
//                       if (direction == DismissDirection.startToEnd) {
//                         print('Marked Completed');
//                         _onDismissed(index);
//                         // doneTask(
//                         //   _tasks.toString(),
//                         //   //"${task["id"]}",
//                         // );
//                       } else {
//                         print('Removed item');
//                         _onDismissed(index);
//                         //deleteTask(tasks.toString()
//                         //"${task["id"]}",;
//                         //);
//                         // setState(() {
//                         //   _tasks.removeAt(index);
//                         // });
//                       }
//                     },
//                     confirmDismiss: (DismissDirection direction) async {
//                       if (direction == DismissDirection.startToEnd) {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           backgroundColor: Theme.of(context).colorScheme.shadow,
//                           content: Text(
//                             'Well Done!',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ));
//                         return true;
//                       } else {
//                         return await showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text(
//                                 "Confirmation",
//                                 style: Theme.of(context).textTheme.displaySmall,
//                               ),
//                               content: Text(
//                                 "Are you sure you want to delete this item?",
//                                 style:
//                                     Theme.of(context).textTheme.displayMedium,
//                               ),
//                               actions: <Widget>[
//                                 TextButton(
//                                   style: TextButton.styleFrom(
//                                     backgroundColor:
//                                         Theme.of(context).colorScheme.shadow,
//                                   ),
//                                   onPressed: () async {
//                                     Navigator.of(context).pop(false);
//                                   },
//                                   child: Text("Cancel",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge),
//                                 ),
//                                 TextButton(
//                                   style: TextButton.styleFrom(
//                                     backgroundColor:
//                                         Theme.of(context).colorScheme.shadow,
//                                   ),
//                                   onPressed: () =>
//                                       Navigator.of(context).pop(true),
//                                   child: Text("Delete",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       }
//                     },
//                     background: Container(
//                       color: Colors.greenAccent[100],
//                       child: Padding(
//                         padding: const EdgeInsets.all(5),
//                         child: Row(
//                           children: [
//                             Text(
//                               'Done',
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     secondaryBackground: Container(
//                       color: Colors.orangeAccent[100],
//                       child: Padding(
//                         padding: const EdgeInsets.all(5),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               'Delete',
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               onReorder: _onReorder,
//             ),
//           )
//         ]);
//       },
//     );
//   }
// }
