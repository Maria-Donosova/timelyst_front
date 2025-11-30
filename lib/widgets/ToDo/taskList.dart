import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import '../../widgets/ToDo/taskItem.dart';
import '../../widgets/ToDo/newTask.dart';
import '../../widgets/ToDo/deleteTask.dart';
import '../../widgets/ToDo/doneTask.dart';
import '../responsive/responsive_widgets.dart';

class TaskListW extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    if (taskProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (taskProvider.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    }

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'ToDo',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          actions: [
            PopupMenuButton<TaskFilter>(
              icon: Icon(Icons.filter_list),
              onSelected: (TaskFilter result) {
                taskProvider.setFilter(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskFilter>>[
                const PopupMenuItem<TaskFilter>(
                  value: TaskFilter.all,
                  child: Text('All Tasks'),
                ),
                const PopupMenuItem<TaskFilter>(
                  value: TaskFilter.active,
                  child: Text('Active Tasks'),
                ),
                const PopupMenuItem<TaskFilter>(
                  value: TaskFilter.completed,
                  child: Text('Completed Tasks'),
                ),
              ],
            ),
            PopupMenuButton<TaskSort>(
              icon: Icon(Icons.sort),
              onSelected: (TaskSort result) {
                taskProvider.setSort(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskSort>>[
                const PopupMenuItem<TaskSort>(
                  value: TaskSort.none,
                  child: Text('Default Order'),
                ),
                const PopupMenuItem<TaskSort>(
                  value: TaskSort.dueDateAsc,
                  child: Text('Due Date (Earliest First)'),
                ),
                const PopupMenuItem<TaskSort>(
                  value: TaskSort.dueDateDesc,
                  child: Text('Due Date (Latest First)'),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Container(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          scrollDirection: Axis.vertical,
                          itemCount: taskProvider.tasks.length,
                          itemBuilder: (ctx, index) {
                            final task = taskProvider.tasks[index];
                            return ReorderableDragStartListener(
                              key: Key(task.id),
                              index: index,
                              child: Dismissible(
                                key: Key(task.id),
                                direction: DismissDirection.horizontal,
                                child: TaskItem(
                                  id: task.id,
                                  title: task.description,
                                  category: task.priority, // Using priority as category for now
                                  dueDate: task.dueDate,
                                  status: task.isCompleted ? 'completed' : 'pending',
                                  onTaskUpdated: (updatedTask) {
                                    taskProvider.updateLocalTask(updatedTask);
                                  },
                                ),
                                onDismissed:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await DoneTaskW.markTaskAsComplete(
                                        context, task.id);
                                  } else {
                                    await DeleteTaskW.deleteTask(
                                        context, task.id);
                                  }
                                },
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    return true;
                                  } else {
                                    return await DeleteTaskW
                                        .showDeleteConfirmation(context, task);
                                  }
                                },
                                background: DoneTaskW(task: task),
                                secondaryBackground: Container(
                                  color: Colors.orangeAccent[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Delete',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            taskProvider.reorderTasks(oldIndex, newIndex);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NewTaskW.show(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}