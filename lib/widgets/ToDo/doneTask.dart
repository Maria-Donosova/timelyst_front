import 'package:flutter/material.dart';
// import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:provider/provider.dart';

class DoneTaskW extends StatelessWidget {
  final Task task;

  DoneTaskW({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  // Method to handle marking a task as complete
  static Future<void> markTaskAsComplete(
      BuildContext context, String taskId) async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final authService = AuthService();
      final authToken = await authService.getAuthToken();

      if (authToken != null) {
        await taskProvider.markTaskAsComplete(taskId, authToken);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.shadow,
            content: Text(
              'Well Done!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      } else {
        throw Exception('Authentication token not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark task as done: $e')),
      );
    }
  }
}
