import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/tasksService.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';

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
            category: selectedCategory!,
            task_type: 'Task',
          );

          // Call the service to create the task
          await TasksService.createTask(authToken, newTask);

          // Refresh the task list
          await taskProvider.fetchTasks(authToken);

          // Capture the scaffold context before popping
          final scaffoldContext = ScaffoldMessenger.of(context);
          final themeData = Theme.of(context);

          // Close the modal first
          Navigator.of(context).pop();

          // Wait for the modal to close completely before showing the SnackBar
          Future.delayed(Duration(milliseconds: 500), () {
            // Show success message using the captured context
            scaffoldContext.showSnackBar(
              SnackBar(
                backgroundColor: themeData.colorScheme.shadow,
                content: Text(
                  'Task created successfully',
                  style: themeData.textTheme.bodyLarge,
                ),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(10),
                elevation: 6,
              ),
            );
          });
        } catch (e) {
          print('Error creating task: $e');
          // Capture the scaffold context before popping
          final scaffoldContext = ScaffoldMessenger.of(context);
          final themeData = Theme.of(context);

          // Close the modal first
          Navigator.of(context).pop();

          // Wait for the modal to close completely before showing the error SnackBar
          Future.delayed(Duration(milliseconds: 500), () {
            // Show error message using the captured context
            scaffoldContext.showSnackBar(
              SnackBar(
                backgroundColor: themeData.colorScheme.shadow,
                content: Text(
                  'Failed to create task: $e',
                  style: themeData.textTheme.bodyLarge,
                ),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(10),
                elevation: 6,
              ),
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _taskController,
                            decoration: InputDecoration(labelText: 'Task'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a value.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            hint: Text('Select Category'),
                            value: selectedCategory,
                            onChanged: (newValue) {
                              setModalState(() {
                                selectedCategory = newValue;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return categories.map((category) {
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: catColor(category),
                                      radius: 5,
                                    ),
                                    SizedBox(width: 8),
                                    Text(category),
                                  ],
                                );
                              }).toList();
                            },
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: catColor(category),
                                      radius: 5,
                                    ),
                                    SizedBox(width: 8),
                                    Text(category),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.shadow,
                                ),
                                onPressed: () => _createTask(context),
                                child: Text(
                                  'Save',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
