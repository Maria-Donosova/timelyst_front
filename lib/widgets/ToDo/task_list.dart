import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/data/tasks.dart';
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

  final _form = GlobalKey<FormState>();
  final _taskDescriptionController = TextEditingController();
  String? selectedCategory;

  // void _saveTask() async {
  //   if (_form.currentState!.validate()) {
  //     final newTask = Task(
  //       id: '', // The backend should generate this
  //       title: _taskDescriptionController.text,
  //       status: 'New',
  //       category: selectedCategory!,
  //       dateCreated: DateTime.now(),
  //       dateChanged: DateTime.now(),
  //       creator: '', // update later
  //     );

  //     try {
  //       // Call your backend to create the task For now, we assume the task is created successfully
  //       //widget.onSave(newTask); // Notify parent widget
  //       Navigator.of(context).pop(); // Close the bottom sheet
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to create task: $e')),
  //       );
  //     }
  //   }
  // }

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
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<dynamic> addNewTaskMethod(BuildContext context) {
    // Create local TextEditingController and category state just for the modal
    final modalTaskController = TextEditingController();
    String? modalSelectedCategory = selectedCategory;

    return showModalBottomSheet(
      useSafeArea: false,
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.5,
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        minHeight: MediaQuery.of(context).size.width * 0.18,
        maxHeight: MediaQuery.of(context).size.width * 0.18,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                            children: [
                              TextFormField(
                                controller: modalTaskController,
                                decoration: InputDecoration(labelText: 'Task'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please provide a value.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              DropdownButtonFormField<String>(
                                hint: Text('Select Category'),
                                value: modalSelectedCategory,
                                onChanged: (newValue) {
                                  setModalState(() {
                                    modalSelectedCategory = newValue;
                                  });
                                  // Also update parent state if needed
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.shadow,
                                    ),
                                    onPressed: () async {
                                      if (_form.currentState!.validate() &&
                                          modalSelectedCategory != null) {
                                        // Get the task provider
                                        final taskProvider =
                                            Provider.of<TaskProvider>(context,
                                                listen: false);

                                        // Get auth token and user ID
                                        final authService = AuthService();
                                        final authToken =
                                            await authService.getAuthToken();
                                        final userId =
                                            await authService.getUserId();

                                        if (authToken != null &&
                                            userId != null) {
                                          try {
                                            // Create a new task
                                            final newTask = Task(
                                              id: '', // The backend will generate this
                                              title: modalTaskController.text,
                                              status: 'New',
                                              category: modalSelectedCategory!,
                                              // dateCreated: DateTime.now(),
                                              // dateChanged: DateTime.now(),
                                              //creator: userId,
                                            );

                                            // Call the service to create the task
                                            await TasksService.createTask(
                                                authToken, newTask);

                                            // Refresh the task list
                                            await taskProvider.fetchTasks(
                                                userId, authToken);

                                            // Close the modal
                                            Navigator.of(context).pop();

                                            // Show success message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .shadow,
                                                content: Text(
                                                  'Task created successfully',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            // Show error message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .shadow,
                                                content: Text(
                                                  'Failed to create task: $e',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Save',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
          },
        );
      },
    );
  }

  // Future<dynamic> addNewTaskMethod(BuildContext context) {
  //   return showModalBottomSheet(
  //     useSafeArea: false,
  //     context: context,
  //     constraints: BoxConstraints(
  //       minWidth: MediaQuery.of(context).size.width * 0.5,
  //       maxWidth: MediaQuery.of(context).size.width * 0.5,
  //       minHeight: MediaQuery.of(context).size.width * 0.18,
  //       maxHeight: MediaQuery.of(context).size.width * 0.18,
  //     ),
  //     builder: (_) {
  //       String? modalSelectedCategory = selectedCategory; // Local copy

  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //           return GestureDetector(
  //             onTap: () {},
  //             behavior: HitTestBehavior.opaque,
  //             child: Column(
  //               children: <Widget>[
  //                 Stack(
  //                   children: <Widget>[
  //                     Card(
  //                       child: Container(
  //                         padding: EdgeInsets.only(
  //                           top: 10,
  //                           left: 10,
  //                           right: 10,
  //                           bottom:
  //                               MediaQuery.of(context).viewInsets.bottom + 50,
  //                         ),
  //                         child: Form(
  //                           key: _form,
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: <Widget>[
  //                               TextFormField(
  //                                 controller: _taskDescriptionController,
  //                                 decoration:
  //                                     InputDecoration(labelText: 'Task'),
  //                                 validator: (value) {
  //                                   if (value!.isEmpty) {
  //                                     return 'Please provide a value.';
  //                                   }
  //                                   return null;
  //                                 },
  //                               ),
  //                               DropdownButton<String>(
  //                                 padding: EdgeInsets.only(top: 15),
  //                                 hint: Text('Select Category'),
  //                                 value: modalSelectedCategory,
  //                                 onChanged: (newValue) {
  //                                   setModalState(() {
  //                                     modalSelectedCategory = newValue;
  //                                   });
  //                                   // Also update the parent's state
  //                                   setState(() {
  //                                     selectedCategory = newValue;
  //                                   });
  //                                 },
  //                                 selectedItemBuilder: (BuildContext context) {
  //                                   if (modalSelectedCategory == null) {
  //                                     return [Text('Select Category')];
  //                                   }
  //                                   return [
  //                                     Row(
  //                                       children: [
  //                                         CircleAvatar(
  //                                           backgroundColor: catColor(
  //                                               modalSelectedCategory!),
  //                                           radius: 5,
  //                                         ),
  //                                         SizedBox(width: 8),
  //                                         Text(modalSelectedCategory!),
  //                                       ],
  //                                     )
  //                                   ];
  //                                 },
  //                                 items: categories.map((category) {
  //                                   return DropdownMenuItem(
  //                                     child: Row(
  //                                       children: [
  //                                         CircleAvatar(
  //                                           backgroundColor: catColor(category),
  //                                           radius: 5,
  //                                         ),
  //                                         SizedBox(width: 8),
  //                                         Text(category),
  //                                       ],
  //                                     ),
  //                                     value: category,
  //                                   );
  //                                 }).toList(),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<dynamic> addNewTaskMethod(BuildContext context) {
  //   return showModalBottomSheet(
  //     useSafeArea: false,
  //     context: context,
  //     constraints: BoxConstraints(
  //       minWidth: MediaQuery.of(context).size.width * 0.5,
  //       maxWidth: MediaQuery.of(context).size.width * 0.5,
  //       minHeight: MediaQuery.of(context).size.width * 0.18,
  //       maxHeight: MediaQuery.of(context).size.width * 0.18,
  //     ),
  //     builder: (_) {
  //       return GestureDetector(
  //         onTap: () {},
  //         behavior: HitTestBehavior.opaque,
  //         child: Column(
  //           children: <Widget>[
  //             Stack(
  //               children: <Widget>[
  //                 Card(
  //                   child: Container(
  //                     padding: EdgeInsets.only(
  //                       top: 10,
  //                       left: 10,
  //                       right: 10,
  //                       bottom: MediaQuery.of(context).viewInsets.bottom + 50,
  //                     ),
  //                     child: Form(
  //                       key: _form,
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: <Widget>[
  //                           TextFormField(
  //                             controller: _taskDescriptionController,
  //                             decoration: InputDecoration(labelText: 'Task'),
  //                             validator: (value) {
  //                               if (value!.isEmpty) {
  //                                 return 'Please provide a value.';
  //                               }
  //                               return null;
  //                             },
  //                           ),
  //                           DropdownButton<String>(
  //                             padding: EdgeInsets.only(top: 15),
  //                             hint: Text(
  //                                 'Select Category'), // Always show hint when no category is selected
  //                             value: selectedCategory,
  //                             onChanged: (newValue) {
  //                               setState(() {
  //                                 selectedCategory = newValue;
  //                               });
  //                             },
  //                             selectedItemBuilder: (BuildContext context) {
  //                               // This builds what is shown in the button when an item is selected
  //                               return categories.map((category) {
  //                                 return Row(
  //                                   children: [
  //                                     CircleAvatar(
  //                                       backgroundColor: catColor(category),
  //                                       radius: 5,
  //                                     ),
  //                                     SizedBox(width: 8),
  //                                     Text(category),
  //                                   ],
  //                                 );
  //                               }).toList();
  //                             },
  //                             items: categories.map((category) {
  //                               return DropdownMenuItem(
  //                                 child: Row(
  //                                   children: [
  //                                     CircleAvatar(
  //                                       backgroundColor: catColor(category),
  //                                       radius: 5,
  //                                     ),
  //                                     SizedBox(width: 8),
  //                                     Text(category),
  //                                   ],
  //                                 ),
  //                                 value: category,
  //                               );
  //                             }).toList(),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
