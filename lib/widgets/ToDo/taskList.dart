import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import '../../widgets/ToDo/taskItem.dart';
import '../../widgets/ToDo/newTask.dart';
import '../../widgets/ToDo/deleteTask.dart';
import '../../widgets/ToDo/doneTask.dart';

class TaskListW extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    if (taskProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (taskProvider.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    }

    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(54),
            child: TabBar(
              tabs: [
                Tab(text: 'ToDo'),
              ],
              labelPadding: EdgeInsets.only(top: 5.3),
              labelStyle: Theme.of(context).textTheme.displayLarge,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              indicatorWeight: 0.001,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
            ),
          ),
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
                              key: Key(task.taskId),
                              index: index,
                              child: Dismissible(
                                key: Key(task.taskId),
                                direction: DismissDirection.horizontal,
                                child: TaskItem(
                                  id: task.taskId,
                                  title: task.title,
                                  category: task.category,
                                  status: task.status,
                                  onTaskUpdated: (updatedTask) async {
                                    await taskProvider.updateTask(
                                        updatedTask.taskId,
                                        updatedTask.title,
                                        updatedTask.category);
                                  },
                                ),
                                onDismissed:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await DoneTaskW.markTaskAsComplete(
                                        context, task.taskId);
                                  } else {
                                    await DeleteTaskW.deleteTask(
                                        context, task.taskId);
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