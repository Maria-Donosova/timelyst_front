import 'package:flutter/material.dart';
// import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:provider/provider.dart';

class DeleteTaskW extends StatelessWidget {
  final Task task;

  DeleteTaskW({required this.task});

  // Method to show the delete confirmation dialog
  static Future<bool> showDeleteConfirmation(
      BuildContext context, Task task) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeleteTaskW(task: task);
          },
        ) ??
        false; // Return false if dialog is dismissed without a choice
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Confirmation",
        style: Theme.of(context).textTheme.displaySmall,
      ),
      content: Text(
        "Are you sure you want to delete this item?",
        style: Theme.of(context).textTheme.displayMedium,
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.shadow,
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "Cancel",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.shadow,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            "Delete",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  // Method to handle the actual task deletion
  static Future<void> deleteTask(BuildContext context, String taskId) async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final authService = AuthService();
      final authToken = await authService.getAuthToken();

      if (authToken != null) {
        await taskProvider.deleteTask(taskId, authToken);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.shadow,
            content: Text(
              'Task deleted',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      } else {
        throw Exception('Authentication token not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }
}
