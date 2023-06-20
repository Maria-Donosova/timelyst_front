// import 'package:flutter/material.dart';

// class TasksList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final tasksData = Provider.of<Tasks>(context);
//     final tasks = tasksData.items;
//     return ListView.builder(
//       scrollDirection: Axis.vertical,
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (ctx, index) => TaskItem(
//         tasks[index].id,
//         tasks[index].title,
//         tasks[index].category,
//         //_deleteTask,
//         //editTask,
//         //tasks[index].catColor,
//         //tasks[index].userId,
//       ),
//     );
//   }
// }
