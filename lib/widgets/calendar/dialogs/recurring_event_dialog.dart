import 'package:flutter/material.dart';

/// Enum for full edit dialog (3 options - used in event details)
enum RecurringEditType {
  thisOccurrence,
  thisAndFuture,
  allOccurrences,
}

/// Enum for simplified drag-and-drop dialog (2 options)
enum DragDropScope {
  thisOccurrence,
  allOccurrences,
}

/// Enum for delete dialog (3 options)
enum RecurringDeleteType {
  thisOccurrence,
  thisAndFuture,
  allOccurrences,
}

/// Dialog widget for recurring event scope selection
/// Provides different dialogs for edit, delete, and drag-and-drop operations
class RecurringEventDialog {
  final int totalOccurrences;

  RecurringEventDialog({required this.totalOccurrences});

  /// Full edit dialog with 3 options (for event details edit)
  /// Returns the selected edit scope or null if cancelled
  Future<RecurringEditType?> showEditDialog(BuildContext context) {
    return showDialog<RecurringEditType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Recurring Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This event is part of a series with $totalOccurrences occurrences.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to edit?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringEditType.thisOccurrence),
            child: const Text('This occurrence only'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringEditType.thisAndFuture),
            child: const Text('This and future occurrences'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringEditType.allOccurrences),
            child: const Text('All occurrences'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Simplified drag-and-drop dialog with 2 options
  /// Returns the selected scope or null if cancelled
  Future<DragDropScope?> showDragDropDialog(BuildContext context) {
    return showDialog<DragDropScope>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Recurring Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This event is part of a series with $totalOccurrences occurrences.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to move?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, DragDropScope.thisOccurrence),
            child: const Text('This occurrence only'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, DragDropScope.allOccurrences),
            child: const Text('All occurrences'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Delete dialog with 3 options
  /// Returns the selected delete scope or null if cancelled
  Future<RecurringDeleteType?> showDeleteDialog(BuildContext context) {
    return showDialog<RecurringDeleteType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This event is part of a series with $totalOccurrences occurrences.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to delete?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringDeleteType.thisOccurrence),
            child: const Text('This occurrence only'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringDeleteType.thisAndFuture),
            child: const Text('This and future occurrences'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, RecurringDeleteType.allOccurrences),
            child: const Text('All occurrences'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
