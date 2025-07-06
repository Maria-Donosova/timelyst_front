import 'package:flutter/material.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/widgets/ToDo/taskItem.dart';

class DraggableTask extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const DraggableTask({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(task.title),
        ),
      ),
      child: TaskItem(
        id: task.taskId,
        title: task.title,
        category: task.category,
        status: task.status,
        onTaskUpdated: onTaskUpdated,
      ),
    );
  }
}
