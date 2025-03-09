import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
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
    print("Entered _fetchTasks in TaskListW");
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

  List<Task> tasks = [];

  void _addNewTask(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });
  }

  final _form = GlobalKey<FormState>();
  final _taskDescriptionController = TextEditingController();
  String? selectedCategory;

  void _saveTask() async {
    if (_form.currentState!.validate()) {
      final newTask = Task(
        id: '', // The backend should generate this
        title: _taskDescriptionController.text,
        status: 'New',
        category: selectedCategory!,
        dateCreated: DateTime.now(),
        dateChanged: DateTime.now(),
        creator: '', // update later
      );

      try {
        // Call your backend to create the task For now, we assume the task is created successfully
        //widget.onSave(newTask); // Notify parent widget
        Navigator.of(context).pop(); // Close the bottom sheet
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create task: $e')),
        );
      }
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
            // Container(),
            // Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            print("Floating button pressed"),
            addNewTaskMethod(context),
            // NewTaskW(
            //   onSave: _addNewTask,
            // ),
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<dynamic> addNewTaskMethod(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: false,
      context: context,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.5,
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        minHeight: MediaQuery.of(context).size.width * 0.18,
        maxHeight: MediaQuery.of(context).size.width * 0.18,
      ),
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Card(
                    //elevation: 5,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                      ),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _taskDescriptionController,
                              decoration: InputDecoration(labelText: 'Task'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please provide a value.';
                                }
                                return null;
                              },
                            ),
                            DropdownButton<String>(
                              padding: EdgeInsets.only(top: 15),
                              hint: Text(
                                'Category',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .fontSize,
                                ),
                              ),
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
                            // ElevatedButton(
                            //   onPressed: _saveTask,
                            //   child: Text('Save',
                            //       style: TextStyle(
                            //         color: Theme.of(context)
                            //             .colorScheme
                            //             .onSecondary,
                            //       )),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor:
                            //         Theme.of(context).colorScheme.secondary,
                            //   ),
                            // ),
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
      },
    );
  }
}
