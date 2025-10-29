import 'package:flutter/material.dart';

import '../ToDo/taskList.dart';
import '../responsive/responsive_widgets.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsivePadding.getHorizontalPadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(child: TaskListW()),
        ],
      ),
    );
  }
}
