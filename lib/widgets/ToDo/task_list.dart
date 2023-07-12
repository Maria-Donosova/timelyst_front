import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/todo/delete_task.dart';
import 'package:timelyst_flutter/widgets/todo/done_task.dart';
import 'task_item.dart';

class TaskListW extends StatefulWidget {
  TaskListW({Key? key}) : super(key: key);

  @override
  State<TaskListW> createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  @override
  Widget build(BuildContext context) {
    List tasks = ['task', 'task1', 'task2'];

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
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
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, index) {
                    return Dismissible(
                      child: TaskItem("1231241242", "DummyTask", "Social"
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
                          doneTask(tasks.toString()
                              //"${task["id"]}",
                              );
                          print('Marked Completed');
                          setState(() {
                            tasks.removeAt(index);
                          });
                        } else {
                          deleteTask(tasks.toString()
                              //"${task["id"]}",;
                              );
                          print('Removed item');
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
            ]);
      },
    );
  }
}
