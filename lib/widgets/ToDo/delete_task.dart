import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/services/authService.dart';
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
      // Get the auth token from secure storage
      final authService = AuthService();
      final authToken = await authService.getAuthToken();

      if (authToken != null) {
        await TasksService.deleteTask(taskId, authToken);
        // Remove the task from the local list
        setState(() {
          tasks.removeWhere((task) => task.id == taskId);
        });
      } else {
        throw Exception('Authentication token not found');
      }
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
