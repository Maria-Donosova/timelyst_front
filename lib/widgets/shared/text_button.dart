import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../todo/new_task.dart';

class TextButtonW extends StatefulWidget {
  const TextButtonW({
    Key? key,
  }) : super(key: key);

  @override
  State<TextButtonW> createState() => _TextButtonWState();
}

class _TextButtonWState extends State<TextButtonW> {
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
        title: "title",
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
      //tasks.add(newTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 21, bottom: 1),
        child: TextButton(
          child: Text(
            '+',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          onPressed: () => _startAddNewTask(context),
        ),
      ),
    );
  }
}
