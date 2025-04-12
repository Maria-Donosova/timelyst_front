import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/services/authService.dart';
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

      // Get the auth token from secure storage
      final authService = AuthService();
      final authToken = await authService.getAuthToken();

      if (authToken != null) {
        await TasksService.updateTask(taskId, authToken, updatedTask);
        // Remove the task from the local list
        setState(() {
          tasks.removeWhere((task) => task.id == taskId);
        });
      } else {
        throw Exception('Authentication token not found');
      }
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
