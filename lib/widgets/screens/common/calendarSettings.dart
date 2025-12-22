import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import '../../../models/calendars.dart';
import '../../../services/googleIntegration/calendarSyncManager.dart';
import '../../shared/customAppbar.dart';
import '../../responsive/responsive_helper.dart';
import '../settings/import_settings_step.dart';
import '../../../models/calendar_import_config.dart';
import '../../../models/import_settings.dart';

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
      providerCalendarId: cal.providerCalendarId,
      title: cal.metadata.title,
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
      final List<Calendar> updatedCalendars = widget.calendars.map((cal) {
        final config = newConfigs.firstWhere(
          (c) => c.providerCalendarId == cal.providerCalendarId,
          orElse: () => CalendarImportConfig(
            providerCalendarId: cal.providerCalendarId,
            title: cal.metadata.title,
            importSettings: cal.preferences.importSettings,
            color: cal.preferences.userColor ?? cal.metadata.parsedColor,
            category: cal.preferences.category ?? 'work',
          ),
        );

        return cal.copyWith(
          preferences: cal.preferences.copyWith(
            importSettings: config.importSettings,
            category: config.category,
            userColor: config.color,
          ),
        );
      }).toList();

      final result = await CalendarSyncManager().saveSelectedCalendars(
        userId: widget.userId,
        email: widget.email,
        selectedCalendars: updatedCalendars,
      );

      if (result.success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Agenda()),
          );
        }
      } else {
        throw Exception(result.error ?? 'Failed to save calendars');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
          ),
    );
  }
}
