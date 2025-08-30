import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import '../../shared/customAppbar.dart';
import '../../layout/leftPanel.dart';
import '../../layout/rightPanel.dart';

class Agenda extends StatefulWidget {
  const Agenda({
    Key? key,
    calendars,
    userId,
    email,
  }) : super(key: key);
  static const routeName = '/tasks-month-calendar';

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
      Provider.of<EventProvider>(context, listen: false).fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final appBar = CustomAppBar();

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          !isLandscape
              ? Expanded(flex: 1, child: LeftPanel())
              : Expanded(flex: 1, child: LeftPanel()),
          !isLandscape
              ? Expanded(
                  flex: 2,
                  child: RightPanel(),
                )
              : Expanded(
                  flex: 2,
                  child: RightPanel(),
                ),
        ]),
      ),
    );
  }
}
