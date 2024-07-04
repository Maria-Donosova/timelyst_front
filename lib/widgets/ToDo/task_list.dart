import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
//import 'package:timelyst_flutter/widgets/todo/delete_task.dart';
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
    List<int> _tasks = List<int>.generate(10, (int index) => index);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    scrollDirection: Axis.vertical,
                    // shrinkWrap: true,
                    // physics: const AlwaysScrollableScrollPhysics(),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final int item = _tasks.removeAt(oldIndex);
                        _tasks.insert(newIndex, item);
                      });
                    },
                    itemCount: _tasks.length,
                    itemBuilder: (ctx, index) {
                      return ReorderableDragStartListener(
                        index: index,
                        key: Key('$index'),
                        child: Dismissible(
                          child: TaskItem(
                            key: ValueKey(_tasks[index]),
                            "1231241242", "DummyTask", "Social",
                            //key: ValueKey("${task["id"]}"),
                            // "${task["id"]}",
                            // "${task["task_description"]}",
                            // "${task["category"]}",
                            // _deleteTask,
                            // "${task['user']["id"]}",
                          ),
                          key: ValueKey(_tasks[index]),
                          direction: DismissDirection.horizontal,
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
                              print('Marked Completed');
                              doneTask(
                                _tasks.toString(),
                                //"${task["id"]}",
                              );
                            } else {
                              print('Removed item');
                            }
                            //deleteTask(tasks.toString()
                            //"${task["id"]}",;
                            //);
                            // setState(() {
                            //   _tasks.removeAt(index);
                            // });
                          },
                          confirmDismiss: (DismissDirection direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text('Well Done!'),
                              ));
                              return true;
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
                          },
                        ),
                      );
                    }),
              )
            ]);
      },
    );
  }
}
