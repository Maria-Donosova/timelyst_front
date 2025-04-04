import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../data/tasks.dart';
import '../shared/categories.dart';
import '/widgets/todo/edit_task.dart';

class TaskItem extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  final String status;
  final Function(Task) onTaskUpdated; // Callback for task updates

  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.onTaskUpdated,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.category;
    final categoryColor = catColor(selectedCategory);

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Card(
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            onLongPress: () => showModalBottomSheet(
              useSafeArea: false,
              context: context,
              builder: (_) {
                return EditTaskW(
                  task: Task(
                    id: widget.id,
                    title: widget.title,
                    status: '',
                    category: widget.category,
                    dateCreated: DateTime.now(),
                    dateChanged: DateTime.now(),
                    //creator: '', // Update with the user ID
                  ),
                  onSave: (updatedTask) async {
                    try {
                      await TasksService.updateTask(
                        updatedTask.id,
                        'authToken', // Replace with actual auth token
                        updatedTask,
                      );
                      widget.onTaskUpdated(updatedTask); // Notify parent widget
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update task: $e')),
                      );
                    }
                  },
                );
              },
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: categoryColor,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Text(
                          widget.category,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 230,
          child: Align(
            alignment: Alignment(-0.98, 0.0),
            child: CircleAvatar(
              backgroundColor: categoryColor,
              radius: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:timelyst_flutter/models/task.dart';

// import '../../data/tasks.dart';
// import '../shared/categories.dart';

// import '/widgets/todo/edit_task.dart';

// class TaskItem extends StatefulWidget {
//   final String id;
//   final String title;
//   final String category;
//   //final String userID;

//   const TaskItem(this.id, this.title, this.category,
//       //this.deleteTx,
//       //this.editTx,
//       //this.doneTx
//       //this.userID
//       {super.key});

//   //final void Function() deleteTx;
//   //final void Function() editTx;
//   //final void Function() doneTx;

//   @override
//   State<TaskItem> createState() => _TaskItemState();
// }

// class _TaskItemState extends State<TaskItem> {
//   @override
//   Widget build(BuildContext context) {
//     final selectedCategory = widget.category;
//     final categoryColor = catColor(selectedCategory);

//     return Stack(
//       alignment: Alignment.topLeft,
//       children: <Widget>[
//         Card(
//           elevation: 4,
//           child: InkWell(
//             splashColor: Colors.blueGrey.withAlpha(30),
//             onTap: () {
//               print('Card tapped.');
//             },
//             onLongPress: () => showModalBottomSheet(
//               useSafeArea: false,
//               context: context,
//               builder: (_) {
//                 return EditTaskW(
//                   task: Task(
//                     id: widget.id,
//                     title: widget.title,
//                     category: widget.category,
//                     dateCreated: DateTime.now(),
//                     dateChanged: DateTime.now(),
//                     creator: '',
//                   ),
//                   onSave: (updatedTask) async {
//                     try {
//                       await TasksService.updateTask(
//                           updatedTask.id, 'authToken', updatedTask);
//                       // Refresh the task list
//                       _fetchTasks();
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Failed to update task: $e')),
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: Container(
//                     padding: const EdgeInsets.all(10.0),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         left: BorderSide(
//                           color: categoryColor,
//                           width: 3,
//                           style: BorderStyle.solid,
//                         ),
//                       ),
//                       shape: BoxShape.rectangle,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Container(
//                           padding: const EdgeInsets.only(bottom: 7),
//                           child: Text(
//                             widget.title,
//                             style: Theme.of(context).textTheme.displaySmall,
//                           ),
//                         ),
//                         Text(
//                           widget.category,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 230,
//           child: Align(
//             alignment: Alignment(-0.98, 0.0),
//             child: CircleAvatar(
//               backgroundColor: categoryColor,
//               radius: 3.5,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
