import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';

import '../calendar/controllers/calendar.dart';
import '../responsive/responsive_widgets.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  Future<void> _refreshData(BuildContext context) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    await taskProvider.fetchTasks();
    
    // Note: Event refreshing is handled by the calendar component
    // based on the current view to avoid duplicate API calls
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.getValue(context, mobile: 4.0, tablet: 6.0, desktop: 8.0),
        top: ResponsiveHelper.getValue(context, mobile: 15.0, tablet: 20.0, desktop: 25.0),
      ),
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
  }
}
