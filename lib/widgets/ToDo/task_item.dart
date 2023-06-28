import 'package:flutter/material.dart';

import '../../widgets/shared/categories.dart';
//import '../../models/task.dart';

class TaskItem extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  //final Function deleteTx;
  //final Function editTx;
  //final String userID;

  const TaskItem(
    this.id,
    this.title,
    this.category,
    //this.deleteTx,
    //this.editTx
    //this.userID,
  );

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  // _startEditTask(BuildContext ctx) {
  //   showModalBottomSheet(
  //     context: ctx,
  //     builder: (_) {
  //       return GestureDetector(
  //         onTap: () {},
  //         behavior: HitTestBehavior.opaque,
  //         child: EditTask(editTask),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.category;
    final catColor = selectedCatColor(selectedCategory);

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Card(
          elevation: 4,
          child: InkWell(
            splashColor: Colors.blueGrey.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            onLongPress: () {
              // _startEditTask(context);
              print('Long press');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: catColor,
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          widget.category,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 230,
          child: Align(
            alignment: Alignment(-0.98, 0.0),
            child: CircleAvatar(
              backgroundColor: catColor,
              radius: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}
