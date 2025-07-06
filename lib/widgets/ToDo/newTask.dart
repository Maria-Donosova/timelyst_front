import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/tasksService.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';

class NewTaskW extends StatefulWidget {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NewTaskW();
      },
    );
  }

  @override
  _NewTaskWState createState() => _NewTaskWState();
}

class _NewTaskWState extends State<NewTaskW> {
  final _form = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  String? selectedCategory;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _createTask(BuildContext context) async {
    if (_form.currentState!.validate() && selectedCategory != null) {
      // Get the task provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Get auth token and user ID
      final authService = AuthService();
      final authToken = await authService.getAuthToken();
      final userId = await authService.getUserId();

      if (authToken != null && userId != null) {
        try {
          // Create a new task with non-null values
          final newTask = Task(
            title: _taskController.text,
            status: 'New',
            category: selectedCategory ?? 'Work',
            task_type: 'Task',
          );

          // Call the service to create the task
          await TasksService.createTask(authToken, newTask);

          // Refresh the task list
          await taskProvider.fetchTasks(authToken);

          // Close the modal first
          Navigator.of(context).pop();

          // Show success message using the current context
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.shadow,
              content: Text(
                'Task created successfully',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              elevation: 6,
            ),
          );
        } catch (e) {
          print('Error creating task: $e');

          // Close the modal first
          Navigator.of(context).pop();

          // Show error message using the current context
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.shadow,
              content: Text(
                'Failed to create task: $e',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              elevation: 6,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              items: ['Work', 'Personal', 'Other'].map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  _createTask(context);
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
