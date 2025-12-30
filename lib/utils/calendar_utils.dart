import 'package:flutter/material.dart';
import '../models/customApp.dart';

class CalendarUtils {
  /// Groups overlapping appointments and returns a list where excess ones are replaced by a summary.
  /// Used for SfCalendar Week View to handle density on narrow screens.
  static List<CustomAppointment> groupAndSummarize(
    List<CustomAppointment> appointments,
    double cellWidth, {
    double minAppWidth = 30.0, // Minimum width for a readable appointment card
  }) {
    if (appointments.isEmpty) return [];

    // Deduplicate: If multiple events have same title, start, end, and category, keep only one
    // This handles duplicates from multiple calendar providers (e.g. Google and Outlook both sync the same event)
    final List<CustomAppointment> uniqueApps = [];
    final Set<String> seen = {};

    for (final app in appointments) {
      // Content-based key for deduplication
      final key = '${app.title}_${app.startTime.toIso8601String()}_${app.endTime.toIso8601String()}_${app.catTitle}';
      if (!seen.contains(key)) {
        uniqueApps.add(app);
        seen.add(key);
      }
    }

    // Separate timed and all-day events (we only group timed ones)
    final timedEvents = uniqueApps.where((e) => !e.isAllDay).toList();
    final allDayEvents = uniqueApps.where((e) => e.isAllDay).toList();

    if (timedEvents.isEmpty) return allDayEvents;

    // Calculate max allowed appointments per time slot
    int maxVisible = (cellWidth / minAppWidth).floor();
    if (maxVisible < 1) maxVisible = 1;

    // Group by days first to keep processing bounded
    final Map<DateTime, List<CustomAppointment>> eventsByDay = {};
    for (final event in timedEvents) {
      final day = DateUtils.dateOnly(event.startTime);
      eventsByDay.putIfAbsent(day, () => []).add(event);
    }

    final List<CustomAppointment> result = List.from(allDayEvents);

    for (final dayEvents in eventsByDay.values) {
      // Sort by start time, then duration
      dayEvents.sort((a, b) {
        int cmp = a.startTime.compareTo(b.startTime);
        if (cmp != 0) return cmp;
        return b.endTime.difference(b.startTime).compareTo(a.endTime.difference(a.startTime));
      });

      // Simple grouping: events with exact same start time
      // Higher complexity (transitive clustering) can be added if needed
      final List<List<CustomAppointment>> groups = [];
      if (dayEvents.isNotEmpty) {
        List<CustomAppointment> currentGroup = [dayEvents[0]];
        for (int i = 1; i < dayEvents.length; i++) {
          if (dayEvents[i].startTime == currentGroup[0].startTime) {
            currentGroup.add(dayEvents[i]);
          } else {
            groups.add(currentGroup);
            currentGroup = [dayEvents[i]];
          }
        }
        groups.add(currentGroup);
      }

      for (final group in groups) {
        if (group.length <= maxVisible) {
          result.addAll(group);
        } else {
          // Keep (maxVisible - 1) events
          final visibleCount = maxVisible - 1;
          result.addAll(group.sublist(0, visibleCount));

          // Create summary appointment for the rest
          final rest = group.sublist(visibleCount);
          final firstRest = rest[0];
          
          result.add(CustomAppointment(
            id: 'summary_${firstRest.id}',
            title: '+${rest.length}',
            startTime: firstRest.startTime,
            endTime: firstRest.endTime,
            isAllDay: false,
            catTitle: 'Summary',
            catColor: Colors.transparent, // We'll handle this in the builder
            groupedEvents: rest,
          ));
        }
      }
    }

    return result;
  }
}
