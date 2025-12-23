import 'package:flutter/material.dart';
import '../../models/calendar_import_config.dart';
import 'import_fields_checklist.dart';
import 'category_selector.dart';

class CalendarImportCard extends StatelessWidget {
  final CalendarImportConfig config;
  final ValueChanged<CalendarImportConfig> onChanged;

  const CalendarImportCard({
    Key? key,
    required this.config,
    required this.onChanged,
  }) : super(key: key);

  Future<bool> _showDeselectConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deselect Calendar?'),
            content: const Text(
                'If you deselect this calendar, all previously imported events from it will be deleted from Timelyst. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Deselect & Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = config.isSelected;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
            width: isSelected ? 2 : 1),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: Colors.black,
                    onChanged: (val) async {
                      if (val == false) {
                        final confirmed =
                            await _showDeselectConfirmation(context);
                        if (confirmed) {
                          onChanged(config.copyWith(isSelected: false));
                        }
                      } else {
                        onChanged(config.copyWith(isSelected: true));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    config.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: isSelected ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !isSelected,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      color: Colors.grey[100],
                      width: double.infinity,
                      child: const Text(
                        'What would you like to import?',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ImportFieldsChecklist(
                      settings: config.importSettings,
                      onChanged: (newSettings) {
                        onChanged(config.copyWith(importSettings: newSettings));
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      color: Colors.grey[100],
                      width: double.infinity,
                      child: const Text(
                        'Assign Category',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CategorySelector(
                      selectedCategory: config.category,
                      onCategorySelected: (newCategory) {
                        onChanged(config.copyWith(category: newCategory));
                      },
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
