import 'package:flutter/material.dart';
import '../../models/import_settings.dart';

class ImportFieldsChecklist extends StatelessWidget {
  final ImportSettings settings;
  final ValueChanged<ImportSettings> onChanged;

  const ImportFieldsChecklist({
    Key? key,
    required this.settings,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'id': 'subject', 'label': 'Subject'},
      {'id': 'description', 'label': 'Description'},
      {'id': 'conferenceInfo', 'label': 'Conference Info'},
      {'id': 'organizer', 'label': 'Organizer'},
      {'id': 'recipients', 'label': 'Recipients'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckbox(
          'All',
          settings.level == ImportLevel.all,
          (val) {
            if (val == true) {
              onChanged(settings.copyWith(level: ImportLevel.all));
            } else {
              onChanged(settings.copyWith(level: ImportLevel.custom));
            }
          },
        ),
        _buildCheckbox(
          'None',
          settings.level == ImportLevel.none,
          (val) {
            if (val == true) {
              onChanged(settings.copyWith(level: ImportLevel.none));
            } else {
              onChanged(settings.copyWith(level: ImportLevel.custom));
            }
          },
        ),
        if (settings.level == ImportLevel.none)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
            child: Text(
              'None: only start and end times and category will be imported',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        const Divider(),
        ...fields.map((field) {
          final isEnabled = settings.level == ImportLevel.all || 
                           (settings.level == ImportLevel.custom && settings.fields.contains(field['id']));
          final isClickable = settings.level == ImportLevel.custom;

          return _buildCheckbox(
            field['label']!,
            isEnabled,
            isClickable
                ? (val) {
                    List<String> newFields = List.from(settings.fields);
                    if (val == true) {
                      newFields.add(field['id']!);
                    } else {
                      newFields.remove(field['id']!);
                    }
                    onChanged(settings.copyWith(fields: newFields));
                  }
                : null,
            disabled: !isClickable,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?>? onChanged, {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : () => onChanged?.call(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: disabled ? Colors.grey : Colors.black))),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFCFCCD7),
              checkColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
