import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import '../../../models/calendars.dart';
import '../../../services/googleIntegration/calendarSyncManager.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_helper.dart';
import '../../settings/import_settings_step.dart';
import '../../../models/calendar_import_config.dart';
import '../../../models/import_settings.dart';
import '../../../services/calendar_preferences_service.dart';
import '../../../services/calendar_exceptions.dart';

class CalendarSettings extends StatefulWidget {
  final List<Calendar> calendars;
  final String userId;
  final String email;

  const CalendarSettings({
    Key? key,
    required this.calendars,
    required this.userId,
    required this.email,
  }) : super(key: key);

  static const routeName = '/calendarSettings';

  @override
  State<CalendarSettings> createState() => _CalendarSettingsState();
}

class _CalendarSettingsState extends State<CalendarSettings> {
  late List<CalendarImportConfig> _configs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _configs = widget.calendars.map((cal) => CalendarImportConfig(
      calendarId: cal.id,
      providerCalendarId: cal.providerCalendarId,
      title: cal.metadata.title ?? '',
      importSettings: cal.preferences.importSettings,
      color: cal.preferences.userColor ?? cal.metadata.parsedColor,
      category: cal.preferences.category ?? 'work',
    )).toList();
  }

  Future<void> _handleSave(List<CalendarImportConfig> newConfigs) async {
    setState(() {
      _isLoading = true;
      _configs = newConfigs;
    });

    try {
      final service = CalendarPreferencesService();
      final results = await service.updateMultipleFromConfigs(newConfigs);
      
      bool anySyncTriggered = results.any((r) => r.syncTriggered);

      if (mounted) {
        if (anySyncTriggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved. Synchronization started...')),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Agenda()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error saving settings: $e';
        if (e is ValidationException && e.errors != null) {
          errorMessage = 'Validation failed: ${e.errors}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ImportSettingsStep(
            configs: _configs,
            onSave: _handleSave,
            onPrevious: () => Navigator.pop(context),
            isLoading: _isLoading,
          ),
    );
  }
}
