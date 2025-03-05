import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../widgets/ToDo/task_item.dart';

class TaskListW extends StatefulWidget {
  @override
  _TaskListWState createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  bool _isInitialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      _isInitialLoad = false;
      _fetchTasks();
    }
  }

  void _fetchTasks() {
    print("Entered _fetchTasks in task_list");
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authService = AuthService();
        final authToken = await authService.getAuthToken();
        final userId = await authService.getUserId();
        print("User ID: $userId");
        if (authToken != null && userId != null) {
          taskProvider.fetchTasks(userId, authToken);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Loading state
    if (taskProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Error state
    if (taskProvider.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          //title: Text('My App'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'ToDo'),
              Tab(text: 'Lists'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for the "ToDo" tab
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
                                  title: task.title,
                                  category: task.category,
                                  status: task.status,
                                  onTaskUpdated: (updatedTask) {
                                    taskProvider.updateTask(
                                        "updatedTask", "", "", "");
                                  },
                                ),
                                onDismissed:
                                    (DismissDirection direction) async {
                                  final storage = FlutterSecureStorage();
                                  final authToken =
                                      await storage.read(key: 'authToken');

                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    await taskProvider.markTaskAsComplete(
                                        task.id, authToken!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                        content: Text(
                                          'Well Done!',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    );
                                  } else {
                                    await taskProvider.deleteTask(
                                        task.id, authToken!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .shadow,
                                        content: Text(
                                          'Task deleted',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    return true;
                                  } else {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Confirmation",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall,
                                          ),
                                          content: Text(
                                            "Are you sure you want to delete this item?",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium,
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .shadow,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                "Cancel",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .shadow,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text(
                                                "Delete",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                background: Container(
                                  color: Colors.greenAccent[100],
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Done',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}
