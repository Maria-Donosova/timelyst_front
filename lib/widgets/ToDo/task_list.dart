import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/shared/categories.dart';
//import 'package:timelyst_flutter/widgets/shared/categories.dart';
//import 'package:timelyst_flutter/widgets/todo/delete_task.dart';
//import 'package:timelyst_flutter/widgets/todo/done_task.dart';
import '../../models/task.dart';
import 'task_item.dart';

class TaskListW extends StatefulWidget {
  TaskListW({Key? key}) : super(key: key);

  @override
  State<TaskListW> createState() => _TaskListWState();
}

class _TaskListWState extends State<TaskListW> {
  //Dummy tasks - remove once connected to database
  // final List<String> _dummyTasks =
  //List.generate(10, (index) => 'TaskItem $index');
  List _dummyTasks = [
    Task(
      id: '1234',
      title: 'Try Me',
      category: 'Personal',
      dateCreated: DateTime.now(),
      dateChanged: DateTime.now(),
      creator: 'Maria Donosova',
    ),
    Task(
      id: '21234',
      title: 'Dare',
      category: 'Work',
      dateCreated: DateTime.now(),
      dateChanged: DateTime.now(),
      creator: 'Maria Donosova',
    ),
    Task(
      id: '35467',
      title: 'Destiny',
      category: 'Friends',
      dateCreated: DateTime.now(),
      dateChanged: DateTime.now(),
      creator: 'Maria Donosova',
    ),
    Task(
      id: '4567',
      title: 'Work it out',
      category: 'Other',
      dateCreated: DateTime.now(),
      dateChanged: DateTime.now(),
      creator: 'Maria Donosova',
    ),
    Task(
      id: '5124',
      title: 'Just do it',
      category: 'Family',
      dateCreated: DateTime.now(),
      dateChanged: DateTime.now(),
      creator: 'Maria Donosova',
    ),
  ];

  //Reodering for reoderable list logic
  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _dummyTasks.removeAt(oldIndex);
    _dummyTasks.insert(newIndex, item);
    setState(() {});
  }

  // sorting
  var _order = 'asc';

  List get _orderedTasks {
    final _sortedTasks = List.of(_dummyTasks);
    _sortedTasks.sort((a, b) {
      final bComesAfterA = a.text.compareTo(b.text);
      return _order == 'asc' ? bComesAfterA : -bComesAfterA;
    });
    return _sortedTasks;
  }

  void _changeOrder() {
    setState(() {
      _order = _order == 'asc' ? 'desc' : 'asc';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _changeOrder,
              icon: Icon(
                _order == 'asc' ? Icons.arrow_downward : Icons.arrow_upward,
              ),
              label:
                  Text('Sort ${_order == 'asc' ? 'Descending' : 'Ascending'}'),
            ),
          ),
          Expanded(
            flex: 1,
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              scrollDirection: Axis.vertical,
              itemCount: _dummyTasks.length,
              itemBuilder: (ctx, index) {
                final item = _dummyTasks[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.horizontal,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: TaskItem(
                      _dummyTasks[index].id,
                      _dummyTasks[index].title,
                      _dummyTasks[index].category,
                      key: UniqueKey(),
                      //key: ValueKey("${task["id"]}"),
                      //"${task["id"]}",
                      // "${task["task_description"]}",
                      // "${task["category"]}",
                      // _deleteTask,
                      // "${task['user']["id"]}",
                    ),
                  ),
                  onDismissed: (DismissDirection direction) {
                    if (direction == DismissDirection.startToEnd) {
                      print('Marked Completed');
                      _dummyTasks.removeAt(index);
                      // doneTask(
                      //   _tasks.toString(),
                      //   //"${task["id"]}",
                      // );
                    } else {
                      print('Removed item');
                      _dummyTasks.removeAt(index);
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                );
              },
              onReorder: _onReorder,
            ),
          )
        ]);
      },
    );
  }
}
