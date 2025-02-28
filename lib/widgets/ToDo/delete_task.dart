import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/tasks.dart';
import '../../models/task.dart';

class DeleteTaskW extends StatefulWidget {
  final Task task;

  DeleteTaskW({required this.task, super.key});

  @override
  State<DeleteTaskW> createState() => _DeleteTaskWState();
}

class _DeleteTaskWState extends State<DeleteTaskW> {
  final List tasks = [
    'task',
    'task1',
    'task2'
  ]; //replace with the list that gets fetched from the backend
  void deleteTask(String taskId) async {
    try {
      await TasksService.deleteTask(
          taskId, 'authToken'); // Replace with actual auth token
      // Remove the task from the local list
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
