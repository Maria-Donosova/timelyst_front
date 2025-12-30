import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final DateTime? dueDate;
  final Function(Task) onTaskUpdated;

  const TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.dueDate,
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

    return Card(
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
                dueDate: widget.dueDate,
                isCompleted: widget.status == 'completed',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              onSave: (updatedTask) {
                widget.onTaskUpdated(updatedTask); // Notify parent widget
              },
            );
          },
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.category,
                            ),
                            if (widget.dueDate != null)
                              Text(
                                DateFormat('MMM d h:mm a')
                                    .format(widget.dueDate!),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              // Precisely center the dot on the 3px wide border line
              // Center of border = 1.5. Dot radius = 3.5. Left = 1.5 - 3.5 = -2.0
              // Center of dot at top edge (0.0). Top = 0 - 3.5 = -3.5
              left: -2.0,
              top: -3.5,
              child: CircleAvatar(
                backgroundColor: categoryColor,
                radius: 3.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
