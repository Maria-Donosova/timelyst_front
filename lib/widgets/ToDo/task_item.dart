import 'package:flutter/material.dart';
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
  //this logic should be extracted into separate widget
  Color _selectedCatColor(String catTitle) {
    //print(catTitle);
    switch (catTitle) {
      case "Work":
        return Color.fromRGBO(8, 100, 237, 1);
      case "Personal":
        return Color.fromRGBO(177, 22, 239, 1);
      case "Kids":
        return Color.fromRGBO(114, 219, 233, 1);
      case "Parents":
        return Color.fromRGBO(0, 149, 63, 1);
      case "Friends":
        return Color.fromRGBO(255, 239, 91, 1);
      case "Misc":
        return Color.fromRGBO(189, 189, 189, 1);
      default:
        return Color.fromRGBO(64, 64, 64, 1);
    }
  }

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
    final _selectedCategory = widget.category;
    final catColor = _selectedCatColor(_selectedCategory);

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
