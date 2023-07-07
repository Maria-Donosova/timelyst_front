import 'package:flutter/material.dart';

import '../shared/title.dart';
import '../shared/todo_list.dart';
import '../shared/text_button.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              !isLandscape
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(flex: 0, child: TitleW()),
                          Flexible(flex: 0, child: TextButtonW()),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(flex: 0, child: TitleW()),
                          Flexible(flex: 0, child: TextButtonW()),
                        ],
                      ),
                    ),
              !isLandscape
                  ? Flexible(
                      child: TaskListW(),
                    )
                  : Flexible(
                      child: TaskListW(),
                    ),
            ],
          ),
        );
      },
    );
  }
}
