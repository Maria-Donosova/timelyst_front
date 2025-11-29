import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/tasksService.dart';
import '../../services/authService.dart';
import '../shared/categories.dart';
import '../ToDo/editTask.dart';

class TaskItem extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  final String status;
  final Function(Task) onTaskUpdated;

  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.onTaskUpdated,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.category;
    final categoryColor = catColor(selectedCategory);

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Card(
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            onLongPress: () => showModalBottomSheet(
              useSafeArea: false,
              context: context,
              builder: (_) {
                return EditTaskW(
                  task: Task(
                    id: widget.id,
                    userId: '', // Placeholder
                    title: widget.title,
                    description: widget.title,
                    priority: widget.category,
                    isCompleted: widget.status == 'completed',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  onSave: (updatedTask) async {
                    try {
                      // Get the auth token from secure storage
                      final authService = AuthService();
                      final authToken = await authService.getAuthToken();

                      if (authToken != null) {
                        final taskInput = {
                          'description': updatedTask.description,
                          'priority': updatedTask.priority,
                          'isCompleted': updatedTask.isCompleted,
                        };
                        
                        await TasksService.updateTask(
                          updatedTask.id,
                          authToken,
                          taskInput,
                        );
                        widget
                            .onTaskUpdated(updatedTask); // Notify parent widget
                      } else {
                        throw Exception('Authentication token not found');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update task: $e')),
                      );
                    }
                  },
                );
              },
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: categoryColor,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Text(
                          widget.category,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 230,
          child: Align(
            alignment: Alignment(-0.98, 0.0),
            child: CircleAvatar(
              backgroundColor: categoryColor,
              radius: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}
