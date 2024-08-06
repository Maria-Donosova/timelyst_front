import 'package:flutter/material.dart';
import '/widgets/todo/edit_task.dart';
import '../shared/categories.dart';

class TaskItem extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  //final String userID;

  const TaskItem(this.id, this.title, this.category,
      //this.deleteTx,
      //this.editTx,
      //this.doneTx
      //this.userID
      {super.key});

  //final void Function() deleteTx;
  //final void Function() editTx;
  //final void Function() doneTx;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.category;
    final categoryColor = catColor(selectedCategory);

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
            onLongPress: () => showModalBottomSheet(
              useSafeArea: false,
              context: context,
              builder: (_) {
                return EditTaskW();
              },
            ),
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
                          color: categoryColor,
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
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        Text(
                          widget.category,
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
              backgroundColor: categoryColor,
              radius: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}
