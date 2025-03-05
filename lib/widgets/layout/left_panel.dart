import 'package:flutter/material.dart';

//import '../shared/title.dart';
import '../todo/task_list.dart';
//import '../todo/new_task.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 6.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       //Flexible(flex: 0, child: TitleW()),
              //       //   Flexible(
              //       //       flex: 0,
              //       //       child: NewTaskW(
              //       //         onSave: (Task) {},
              //       //       )),
              //     ],
              //   ),
              // ),
              Flexible(child: TaskListW()),
            ],
          ),
        );
      },
    );
  }
}
