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

class _AgendaState extends State<Agenda> with WidgetsBindingObserver {
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      // Always invalidate cache when app resumes to catch external changes
      eventProvider.invalidateCache();
      print('📱 [Agenda] App resumed - cache invalidated for fresh data');
      
      if (_lastFetchTime == null || now.difference(_lastFetchTime!).inMinutes >= 5) {
        _refreshData();
      } else {
        print('📱 [Agenda] Recent fetch detected, cache invalidated but not forcing immediate refresh');
      }
    }
  }

  void _refreshData() {
    final timestamp = DateTime.now();
    print('🔄 [Agenda] Starting parallel data refresh at ${timestamp}');
    
    _lastFetchTime = timestamp;
    
    // Load tasks and initial events in parallel for better UX
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    // Start both operations concurrently - give them time for CalDAV operations
    print('📊 [Agenda] Starting tasks and events loading - this may take up to 60 seconds for Apple CalDAV sync...');
    Future.wait([
      taskProvider.fetchTasks(),
      eventProvider.fetchDayViewEvents(isParallelLoad: true), // Load today's events with parallel timeout
    ]).then((_) {
      print('✅ [Agenda] Parallel data refresh completed successfully');
    }).catchError((error) {
      print('❌ [Agenda] Parallel data refresh failed: $error');
      // Don't prevent the UI from working even if initial load fails
    });
    
    // Calendar component will still handle additional event fetching for view changes
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
