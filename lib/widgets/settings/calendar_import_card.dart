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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: Colors.grey[100],
              width: double.infinity,
              child: const Text(
                'What would you like to import?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              color: Colors.grey[100],
              width: double.infinity,
              child: const Text(
                'Assign Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
    );
  }
}
