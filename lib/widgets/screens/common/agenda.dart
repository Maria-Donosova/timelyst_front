import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import '../../shared/customAppbar.dart';
import '../../layout/leftPanel.dart';
import '../../layout/rightPanel.dart';

class Agenda extends StatefulWidget {
  final bool? syncInProgress;
  final String? syncIntegrationType;
  
  const Agenda({
    Key? key,
    calendars,
    userId,
    email,
    this.syncInProgress,
    this.syncIntegrationType,
  }) : super(key: key);
  static const routeName = '/tasks-month-calendar';

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> with WidgetsBindingObserver {
  DateTime? _lastFetchTime;
  bool _isSyncInProgress = false;
  String? _syncIntegrationType;
  DateTime? _syncStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSyncInProgress();
      _refreshData();
    });
  }

  void _checkForSyncInProgress() {
    // Check if sync was explicitly passed from calendar settings
    if (widget.syncInProgress == true) {
      final now = DateTime.now();
      setState(() {
        _isSyncInProgress = true;
        _syncStartTime = now;
        _syncIntegrationType = widget.syncIntegrationType ?? 'Calendar';
      });
      
      print('🔄 [Agenda] Sync in progress detected - monitoring for completion (${_syncIntegrationType})');
      _monitorSyncProgress();
    }
  }

  void _monitorSyncProgress() {
    if (!_isSyncInProgress) return;
    
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    int eventCountBefore = eventProvider.events.length;
    
    // Poll for events on current day to detect sync completion
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isSyncInProgress || !mounted) {
        timer.cancel();
        return;
      }
      
      print('📡 [Agenda] Checking for new events from sync...');
      
      // Force cache invalidation and fetch today's events
      eventProvider.invalidateCache();
      eventProvider.fetchDayViewEvents(date: DateTime.now()).then((_) {
        final currentEventCount = eventProvider.events.length;
        
        // Check if new events have been added
        if (currentEventCount > eventCountBefore && _isSyncInProgress) {
          print('✅ [Agenda] Events detected - sync appears complete (${currentEventCount} vs ${eventCountBefore} events)');
          _completeSyncProgress();
          timer.cancel();
        } else if (_syncStartTime != null && 
                   DateTime.now().difference(_syncStartTime!).inMinutes > 3) {
          // Timeout after 3 minutes
          print('⏰ [Agenda] Sync monitoring timeout');
          _completeSyncProgress(timeout: true);
          timer.cancel();
        }
      }).catchError((error) {
        print('❌ [Agenda] Error checking sync progress: $error');
      });
    });
  }

  void _completeSyncProgress({bool timeout = false}) {
    if (!mounted) return;
    
    setState(() {
      _isSyncInProgress = false;
      _syncIntegrationType = null;
      _syncStartTime = null;
    });
    
    if (timeout) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white, size: 16),
              SizedBox(width: 12),
              Text('Calendar sync is taking longer than expected'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 12),
              Text('${_syncIntegrationType ?? 'Calendar'} sync completed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    }
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
        child: Stack(
          children: [
            // Main content
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            
            // Sync progress indicator
            if (_isSyncInProgress)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_syncIntegrationType ?? 'Calendar'} sync in progress...',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_syncStartTime != null)
                        Text(
                          '${DateTime.now().difference(_syncStartTime!).inSeconds}s',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
