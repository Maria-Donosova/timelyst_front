import 'package:flutter/material.dart';
import '../todo/task_item.dart';
import '../todo/new_task.dart';
import '../../models/task.dart';

class TaskListW extends StatefulWidget {
  TaskListW({Key? key}) : super(key: key);

  @override
  State<TaskListW> createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  List tasks = [];

  void _startAddNewTask(BuildContext mctx) {
    showModalBottomSheet(
      context: mctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTaskW(addNewTask),
        );
      },
    );
  }

  addNewTask(String taskTitle, String taskCategory, Color catColor) {
    final newTask = Task(
        id: DateTime.now().toString(),
        title: "titile",
        dateCreated: DateTime.now(),
        dateChanged: DateTime.now(),
        creator: "Name"
        // title: taskTitle,
        // category: taskCategory,
        // catColor: catColor,
        // dateCreated: DateTime.now(),
        // dateChanged: DateTime.now(),
        // userId: DateTime.now().toString(),
        );

    setState(() {
      tasks.add(newTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    List tasks = ['task', 'task1'];

    return Container(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              !isLandscape
                  ? SizedBox(
                      height: constraints.maxHeight * 0.97,
                      child: ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final task = tasks.removeAt(oldIndex);
                            tasks.insert(newIndex, task);
                          });
                        },
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (ctx, index) {
                          return Dismissible(
                            child:
                                TaskItem("1231241242", "DummyTask", "Personal"
                                    // "${task["id"]}",
                                    // "${task["task_description"]}",
                                    // "${task["category"]}",
                                    // _deleteTask,
                                    // "${task['user']["id"]}",
                                    ),
                            key: ValueKey(tasks[index]),
                            background: Container(
                              color: Colors.orangeAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  children: const [
                                    Text(
                                      'Done',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.redAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onDismissed: (DismissDirection direction) {
                              if (direction == DismissDirection.startToEnd) {
                                print("Done");
                                setState(() {
                                  tasks.removeAt(index);
                                });
                              } else {
                                print('Remove item');
                                setState(() {
                                  tasks.removeAt(index);
                                });
                              }
                            },
                            confirmDismiss: (DismissDirection direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Well Done"),
                                      );
                                    });
                              } else {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Delete Confirmation"),
                                      content: const Text(
                                          "Are you sure you want to delete this item?"),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("Delete")),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Cancel"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              ;
                              return null;
                            },
                          );
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                child: TextButton(
                  child: Text(
                    '+ Add new',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  onPressed: () => _startAddNewTask(context),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
