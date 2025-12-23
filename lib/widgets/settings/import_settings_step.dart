import 'package:flutter/material.dart';
import '../../models/calendar_import_config.dart';
import 'calendar_import_cards_row.dart';
import '../responsive/responsive_button.dart';

class ImportSettingsStep extends StatefulWidget {
  final List<CalendarImportConfig> configs;
  final Function(List<CalendarImportConfig>) onSave;
  final VoidCallback onPrevious;
  final bool isLoading;

  const ImportSettingsStep({
    Key? key,
    required this.configs,
    required this.onSave,
    required this.onPrevious,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _ImportSettingsStepState createState() => _ImportSettingsStepState();
}

class _ImportSettingsStepState extends State<ImportSettingsStep> {
  late List<CalendarImportConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.configs);
  }

  void _onConfigChanged(int index, CalendarImportConfig newConfig) {
    setState(() {
      _configs[index] = newConfig;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          const Text(
            "Choose what you'd like to import",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Start and end time, identificators and timezone always get imported for the selected calendars",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          CalendarImportCardsRow(
            configs: _configs,
            onConfigChanged: _onConfigChanged,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Previous',
                    onPressed: widget.onPrevious,
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ResponsiveButton(
                    text: widget.isLoading ? 'Saving...' : 'Next',
                    onPressed: () {
                      final selectedButNoCategory = _configs
                          .where((c) => c.isSelected && c.category.isEmpty)
                          .toList();

                      if (selectedButNoCategory.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please assign a category to all selected calendars'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      widget.onSave(_configs);
                    },
                    isLoading: widget.isLoading,
                    type: ButtonType.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
