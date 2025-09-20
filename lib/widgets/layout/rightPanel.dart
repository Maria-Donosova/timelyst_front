import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';

import '../calendar/controllers/calendar.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  Future<void> _refreshData(BuildContext context) async {
    print('🔄 [RightPanel] Pull-to-refresh triggered - forcing full refresh');
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    await Future.wait([
      eventProvider.fetchAllEvents(forceFullRefresh: true),
      taskProvider.fetchTasks(),
    ]);
    
    print('✅ [RightPanel] Pull-to-refresh completed');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              !isLandscape
                  ? Flexible(flex: 0, child: Container())
                  : Flexible(
                      flex: 0,
                      child: Container(),
                    ),
              !isLandscape
                  ? Flexible(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshData(context),
                        child: CalendarW(),
                      ),
                    )
                  : Flexible(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshData(context),
                        child: CalendarW(),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
