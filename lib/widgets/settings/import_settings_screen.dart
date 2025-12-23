import 'package:flutter/material.dart';
import '../../models/calendars.dart';
import '../../models/import_settings.dart';
import '../../services/calendar_preferences_service.dart';
import '../../services/calendar_exceptions.dart';
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
  late bool _isSelected;
  bool _isSaving = false;
  bool _isSaving = false;
  final CalendarPreferencesService _service = CalendarPreferencesService();

  @override
  void initState() {
    super.initState();
    _importSettings = widget.calendar.preferences.importSettings;
    _category = widget.calendar.preferences.category ?? 'work';
    _color = widget.calendar.preferences.userColor ?? widget.calendar.metadata.parsedColor;
    _isSelected = widget.calendar.isSelected;
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final preferences = CalendarPreferences(
        importSettings: _importSettings,
        category: _category,
        userColor: _color,
        isSelected: _isSelected,
      );

      final result = await _service.updatePreferences(
        widget.calendar.id,
        preferences,
      );

      if (mounted) {
        String message = 'Settings saved successfully';
        if (result.syncTriggered) {
          message += '. Synchronization started...';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save settings: $e';
        if (e is ValidationException && e.errors != null) {
          errorMessage = 'Validation failed: ${e.errors}';
        } else if (e is UnauthorizedException) {
          errorMessage = 'Unauthorized. Please log in again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
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
