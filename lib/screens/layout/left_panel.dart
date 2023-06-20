import 'package:flutter/material.dart';

import '../../widgets/shared/title.dart';
import '../../widgets/ToDo/task_list.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 15),
          child: Column(
            children: [
              !isLandscape
                  ? Container(
                      //height: constraints.maxHeight * 0.04,
                      //fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                      child: TitleW(),
                    )
                  : const FittedBox(
                      //height: constraints.maxHeight * 0.09,
                      alignment: Alignment.bottomLeft,
                      child: TitleW(),
                    ),
              !isLandscape
                  ? Container(
                      height: constraints.maxHeight * 0.9,
                      alignment: Alignment.bottomLeft,
                      child: TaskListW(),
                    )
                  : Container(
                      height: constraints.maxHeight * 0.9,
                      child: TaskListW(),
                    ),
            ],
          ),
        );
      },
    );
  }
}
