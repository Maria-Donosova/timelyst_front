import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/tasks.dart';
import '../../models/task.dart';

class DoneTaskW extends StatefulWidget {
  final Task task;

  DoneTaskW({required this.task, super.key});

  @override
  State<DoneTaskW> createState() => _DoneTaskWState();
}

class _DoneTaskWState extends State<DoneTaskW> {
  final List tasks = [
    'task',
    'task1',
    'task2'
  ]; //replace with the list that gets fetched from the backend

  void doneTask(String taskId) async {
    try {
      final task = tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task..task_type = 'completed'; // Update task status
      await TasksService.updateTask(taskId, 'authToken', updatedTask);
      // Remove the task from the local list
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark task as done: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

// void doneTask(String id) {
//   tasks.removeWhere((tasks) => tasks.id == id);
//   tasks.where((tasks) => tasks.id == id);
//   isDone = true;
// }

//backend: schema & method should be updated & developed
// String markCompleteTask() {
//   return """
//   mutation markCompelte(\$id: String!){
//     markCompelte(id: \$id) {
//       status
//     }
//   }
//   """;
// }
