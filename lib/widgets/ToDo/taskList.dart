import 'package:flutter/material.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
//import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
//import 'package:timelyst_flutter/widgets/shared/categories.dart';
import '../../widgets/ToDo/taskItem.dart';
import '../../widgets/ToDo/newTask.dart';
import '../../widgets/ToDo/deleteTask.dart';
import '../../widgets/ToDo/doneTask.dart';

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
    print("Entered _fetchTasks in TaskListW");
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (taskProvider.tasks.isEmpty && !taskProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authService = AuthService();
        final authToken = await authService.getAuthToken();
        final userId = await authService.getUserId();
        print("User ID: $userId");
        if (authToken != null) {
          taskProvider.fetchTasks(authToken);
        }
      });
    }
  }

  List<Task> tasks = [];

  //final _form = GlobalKey<FormState>();
  String? selectedCategory;

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
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(54), // Set a fixed height for the TabBar
            child: TabBar(
              tabs: [
                Tab(text: 'ToDo'),
                // Tab(text: 'Lists'),
                // Tab(text: 'Notes'),
              ],
              labelPadding: EdgeInsets.only(top: 5.3),
              labelStyle: Theme.of(context).textTheme.displayLarge,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.white,
              indicatorWeight: 0.001,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              //indicator: BoxDecoration(),
            ),
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
                                    final authService = AuthService();
                                    final authToken =
                                        await authService.getAuthToken();
                                    if (authToken != null) {
                                      await taskProvider.updateTask(
                                          updatedTask.taskId,
                                          authToken,
                                          updatedTask.title,
                                          updatedTask.category);
                                      // Refresh the task list after update
                                      await taskProvider.fetchTasks(authToken);
                                    }
                                  },
                                ),
                                onDismissed:
                                    (DismissDirection direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // Use the extracted DoneTaskW component
                                    await DoneTaskW.markTaskAsComplete(
                                        context, task.taskId);
                                  } else {
                                    // Use the extracted DeleteTaskW component
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
                                    // Use the extracted DeleteTaskW component for confirmation
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
            // Container(),
            // Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Floating button pressed");
            NewTaskW.show(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  // The addNewTaskMethod has been moved to the NewTaskW widget
}
