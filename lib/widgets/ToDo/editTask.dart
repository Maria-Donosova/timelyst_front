import 'package:flutter/material.dart';

import '../shared/categories.dart';
import '../../services/tasksService.dart';
import '../../models/task.dart';
import '../../services/authService.dart';

class EditTaskW extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;

  EditTaskW({
    required this.task,
    required this.onSave,
  });

  @override
  State<EditTaskW> createState() => _EditTaskWState();
}

class _EditTaskWState extends State<EditTaskW> {
  final _form = GlobalKey<FormState>();
  final _taskDescriptionController = TextEditingController();
  String? selectedCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _taskDescriptionController.text = widget.task.description;
    selectedCategory = widget.task.priority; // Using priority as category
    if (widget.task.dueDate != null) {
      selectedDate = widget.task.dueDate;
      selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate!);
    }
  }

  void _saveTask() async {
    if (_form.currentState!.validate()) {
      DateTime? finalDueDate = selectedDate;
      if (finalDueDate != null && selectedTime != null) {
        finalDueDate = DateTime(
          finalDueDate.year,
          finalDueDate.month,
          finalDueDate.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );
      }

      final updatedTask = Task(
        id: widget.task.id,
        userId: widget.task.userId,
        title: widget.task.title,
        description: _taskDescriptionController.text,
        priority: selectedCategory!,
        isCompleted: widget.task.isCompleted,
        dueDate: finalDueDate,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        // Get the auth token from secure storage
        final authService = AuthService();
        final authToken = await authService.getAuthToken();

        if (authToken != null) {
          final taskInput = {
            'description': updatedTask.description,
            'priority': updatedTask.priority,
            'isCompleted': updatedTask.isCompleted,
            if (finalDueDate != null) 'dueDate': finalDueDate.toUtc().toIso8601String(),
          };
          
          await TasksService.updateTask(
            updatedTask.id,
            authToken,
            taskInput,
          );
          widget.onSave(updatedTask); // Notify parent widget
          Navigator.of(context).pop(); // Close the bottom sheet

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.shadow,
              content: Text(
                'Task updated successfully',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        } else {
          throw Exception('Authentication token not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.shadow,
            content: Text(
              'Failed to update task: $e',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    children: <Widget>[
                      TextFormField(
                        controller: _taskDescriptionController,
                        decoration: InputDecoration(labelText: 'Task Title'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              hint: Text('Select Category'),
                              value: selectedCategory,
                              onChanged: (newValue) {
                                setState(() {
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
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null && picked != selectedDate) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: selectedDate != null
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor,
                                  ),
                                  if (selectedDate != null) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (picked != null && picked != selectedTime) {
                                setState(() {
                                  selectedTime = picked;
                                  if (selectedDate == null) {
                                    selectedDate = DateTime.now();
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: selectedTime != null
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor,
                                  ),
                                  if (selectedTime != null) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      selectedTime!.format(context),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
                            onPressed: _saveTask,
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
  }
}
