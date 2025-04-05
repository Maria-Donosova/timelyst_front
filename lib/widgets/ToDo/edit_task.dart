import 'package:flutter/material.dart';

import '../shared/categories.dart';
import '../../data/tasks.dart';
import '../../models/task.dart';

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

  @override
  void initState() {
    super.initState();
    _taskDescriptionController.text = widget.task.title;
    selectedCategory = widget.task.category;
  }

  void _saveTask() async {
    if (_form.currentState!.validate()) {
      final updatedTask = Task(
        id: widget.task.id,
        title: _taskDescriptionController.text,
        status: '',
        category: selectedCategory!,
        // dateCreated: widget.task.dateCreated,
        // dateChanged: DateTime.now(),
        //creator: widget.task.creator,
      );

      try {
        await TasksService.updateTask(
          updatedTask.id,
          'authToken', // Replace with actual auth token
          updatedTask,
        );
        widget.onSave(updatedTask); // Notify parent widget
        Navigator.of(context).pop(); // Close the bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey,
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    ),
                    shape: BoxShape.rectangle,
                  ),
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
                        DropdownButton<String>(
                          hint: Text('Category'),
                          value: selectedCategory,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              child: Text(category),
                              value: category,
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          onPressed: _saveTask,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
