import 'package:flutter/material.dart';

class EventActionButtons extends StatelessWidget {
  final bool isLoading;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const EventActionButtons({
    Key? key,
    required this.isLoading,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          Row(
            children: [
              if (isEditing) ...[
                TextButton(
                  onPressed: isLoading ? null : onDelete,
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                )
              ],
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: isLoading ? null : onSave,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
