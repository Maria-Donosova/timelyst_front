import 'package:flutter/material.dart';
import '../../models/calendars.dart';
import '../../models/import_settings.dart';
import '../../services/import_settings_service.dart';
import 'import_fields_checklist.dart';
import 'category_selector.dart';
import '../shared/customAppbar.dart';
import '../responsive/responsive_button.dart';

class ImportSettingsScreen extends StatefulWidget {
  final Calendar calendar;

  const ImportSettingsScreen({
    Key? key,
    required this.calendar,
  }) : super(key: key);

  @override
  _ImportSettingsScreenState createState() => _ImportSettingsScreenState();
}

class _ImportSettingsScreenState extends State<ImportSettingsScreen> {
  late ImportSettings _importSettings;
  late String _category;
  late Color _color;
  bool _isSaving = false;
  final ImportSettingsService _service = ImportSettingsService();

  @override
  void initState() {
    super.initState();
    _importSettings = widget.calendar.preferences.importSettings;
    _category = widget.calendar.preferences.category ?? 'work';
    _color = widget.calendar.preferences.userColor ?? widget.calendar.metadata.parsedColor;
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _service.updatePreferences(
        calendarId: widget.calendar.id,
        importSettings: _importSettings,
        color: _color,
        category: _category,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Settings: ${widget.calendar.metadata.title}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            const Text(
              'What would you like to import?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ImportFieldsChecklist(
              settings: _importSettings,
              onChanged: (val) => setState(() => _importSettings = val),
            ),
            const SizedBox(height: 32),
            const Text(
              'Assign Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CategorySelector(
              selectedCategory: _category,
              onCategorySelected: (val) => setState(() => _category = val),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ResponsiveButton(
                text: _isSaving ? 'Saving...' : 'Save Preferences',
                onPressed: _isSaving ? null : _save,
                type: ButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
