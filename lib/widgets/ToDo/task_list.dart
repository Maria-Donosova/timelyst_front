import 'package:flutter/material.dart';
import '../../data/tasks.dart';
import '../../models/task.dart';
import 'task_item.dart';

class TaskListW extends StatefulWidget {
  @override
  State<TaskListW> createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await TasksService.fetchUserTasks('userId', 'authToken');
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      print('Failed to fetch tasks: $e');
    }
  }

  void _onTaskUpdated(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (ctx, index) {
        final task = _tasks[index];
        return TaskItem(
          id: task.id,
          title: task.title,
          category: task.category,
          onTaskUpdated: _onTaskUpdated,
        );
      },
    );
  }
}

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
