import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import '../../../models/calendars.dart';
import '../../../services/googleIntegration/calendarSyncManager.dart';
import '../../shared/customAppbar.dart';
import '../../shared/categories.dart';

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
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.generate(
      widget.calendars.length,
      (index) => widget.calendars[index].preferences.category ?? 'Work',
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        ),
      ),
    );
  }

  Widget _buildCalendarSection(int index) {
    final calendar = widget.calendars[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Calendar title header
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              calendar.metadata.title,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
              ),
            ),
          ),
          _buildCalendarImportSettings(index),
          const SizedBox(height: 12),
          _buildCategorySelection(index),
        ],
      ),
    );
  }

  Widget _buildCalendarImportSettings(int index) {
    final calendar = widget.calendars[index];
    final importSettings = calendar.preferences.importSettings;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('What would you like to import?'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                // 'All' Checkbox
                _buildCheckbox(
                  'All',
                  importSettings.importAll,
                  (value) {
                    bool newValue = value ?? false;
                    setState(() {
                      final updatedCalendar = calendar.copyWith(
                        preferences: calendar.preferences.copyWith(
                          importSettings: calendar.preferences.importSettings.copyWith(
                            importAll: newValue,
                            // When "All" is checked, set all to true
                            // When "All" is unchecked, reset all to false so user can choose individually
                            importSubject: newValue ? true : false,
                            importBody: newValue ? true : false,
                            importConferenceInfo: newValue ? true : false,
                            importOrganizer: newValue ? true : false,
                            importRecipients: newValue ? true : false,
                          ),
                        ),
                      );
                      widget.calendars[index] = updatedCalendar;
                      print('  📋 Import All: ${updatedCalendar.preferences.importSettings.importAll}');
                      print('  📋 Import Subject: ${updatedCalendar.preferences.importSettings.importSubject}');
                      print('  📋 Import Body: ${updatedCalendar.preferences.importSettings.importBody}');
                    });
                  },
                ),

                // Individual Checkboxes
                _buildCheckbox(
                  'Subject',
                  importSettings.importSubject,
                  importSettings.importAll ? null : (value) => setState(() {
                    final updatedCalendar = calendar.copyWith(
                      preferences: calendar.preferences.copyWith(
                        importSettings: calendar.preferences.importSettings.copyWith(
                          importSubject: value ?? false,
                        ),
                      ),
                    );
                    widget.calendars[index] = updatedCalendar;
                    _updateAllCheckboxState(widget.calendars[index]);
                  }),
                ),
                _buildCheckbox(
                  'Description',
                  importSettings.importBody,
                  importSettings.importAll ? null : (value) => setState(() {
                    final updatedCalendar = calendar.copyWith(
                      preferences: calendar.preferences.copyWith(
                        importSettings: calendar.preferences.importSettings.copyWith(
                          importBody: value ?? false,
                        ),
                      ),
                    );
                    widget.calendars[index] = updatedCalendar;
                    _updateAllCheckboxState(widget.calendars[index]);
                  }),
                ),
                _buildCheckbox(
                  'Conference Info',
                  importSettings.importConferenceInfo,
                  importSettings.importAll ? null : (value) => setState(() {
                    final updatedCalendar = calendar.copyWith(
                      preferences: calendar.preferences.copyWith(
                        importSettings: calendar.preferences.importSettings.copyWith(
                          importConferenceInfo: value ?? false,
                        ),
                      ),
                    );
                    widget.calendars[index] = updatedCalendar;
                    _updateAllCheckboxState(widget.calendars[index]);
                  }),
                ),
                _buildCheckbox(
                  'Organizer',
                  importSettings.importOrganizer,
                  importSettings.importAll ? null : (value) => setState(() {
                    final updatedCalendar = calendar.copyWith(
                      preferences: calendar.preferences.copyWith(
                        importSettings: calendar.preferences.importSettings.copyWith(
                          importOrganizer: value ?? false,
                        ),
                      ),
                    );
                    widget.calendars[index] = updatedCalendar;
                    _updateAllCheckboxState(widget.calendars[index]);
                  }),
                ),
                _buildCheckbox(
                  'Recipients',
                  importSettings.importRecipients,
                  importSettings.importAll ? null : (value) => setState(() {
                    final updatedCalendar = calendar.copyWith(
                      preferences: calendar.preferences.copyWith(
                        importSettings: calendar.preferences.importSettings.copyWith(
                          importRecipients: value ?? false,
                        ),
                      ),
                    );
                    widget.calendars[index] = updatedCalendar;
                    _updateAllCheckboxState(widget.calendars[index]);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateAllCheckboxState(Calendar calendar) {
    final importSettings = calendar.preferences.importSettings;
    bool allChecked = importSettings.importSubject &&
        importSettings.importBody &&
        importSettings.importConferenceInfo &&
        importSettings.importOrganizer &&
        importSettings.importRecipients;

    // Find the index of this calendar and update it properly
    final calendarIndex = widget.calendars.indexWhere((c) => c.providerCalendarId == calendar.providerCalendarId);
    if (calendarIndex != -1) {
      setState(() {
        final updatedCalendar = calendar.copyWith(
          preferences: calendar.preferences.copyWith(
            importSettings: calendar.preferences.importSettings.copyWith(
              importAll: allChecked,
            ),
          ),
        );
        widget.calendars[calendarIndex] = updatedCalendar;
      });
    }
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?)? onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Checkbox(
          checkColor: Colors.grey[800],
          activeColor: const Color.fromRGBO(207, 204, 215, 100),
          visualDensity: VisualDensity.compact,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCategorySelection(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Assign Category'),
          ..._buildCategoryRows(index),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryRows(int index) {
    return categories.chunked(2).map((rowCategories) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: rowCategories.map((category) {
          return Container(
            width: 150,
            child: RadioListTile<String>(
              activeColor: catColor(category),
              fillColor: WidgetStateProperty.all(catColor(category)),
              dense: true,
              value: category,
              groupValue: _selectedCategories[index],
              title: Text(category),
              onChanged: (String? value) => setState(() {
                if (value == null) return;

                _selectedCategories[index] = value;

                // Create new calendar with updated preferences
                final updatedCalendar = widget.calendars[index].copyWith(
                  preferences: widget.calendars[index].preferences.copyWith(
                    category: value,
                  ),
                );

                // Update the calendars list
                widget.calendars[index] = updatedCalendar;
              }),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  bool _isSaving = false;

  Future<void> _navigateToAgenda() async {
    if (_isSaving) return; // Prevent duplicate operations
    
    setState(() {
      _isSaving = true;
    });

    // Debug: Print current state of each calendar before saving
    for (int i = 0; i < widget.calendars.length; i++) {
      final calendar = widget.calendars[i];
      final importSettings = calendar.preferences.importSettings;
      print('📅 Calendar $i: "${calendar.metadata.title}"');
      print('  📋 Import All: ${importSettings.importAll}');
      print('  📋 Import Subject: ${importSettings.importSubject}');
      print('  📋 Import Body: ${importSettings.importBody}');
      print('  📋 Import Conference: ${importSettings.importConferenceInfo}');
      print('  📋 Import Organizer: ${importSettings.importOrganizer}');
      print('  📋 Import Recipients: ${importSettings.importRecipients}');
      print('  📋 Category: ${calendar.preferences.category}');
    }

    // Filter out calendars that are not selected (no import options enabled)
    final _selectedCalendars = widget.calendars.where((calendar) {
      final importSettings = calendar.preferences.importSettings;
      return importSettings.importAll ||
          importSettings.importSubject ||
          importSettings.importBody ||
          importSettings.importConferenceInfo ||
          importSettings.importOrganizer ||
          importSettings.importRecipients;
    }).toList();

    
    // Enhanced logging: Show details of each selected calendar
    for (int i = 0; i < _selectedCalendars.length; i++) {
      final calendar = _selectedCalendars[i];
      print('  📅 Title: "${calendar.metadata.title}"');
      print('  📅 Source: ${calendar.source}');
      print('  📅 Provider ID: ${calendar.providerCalendarId}');
      print('  📅 Import Settings: ${calendar.preferences.importSettings.importAll ? "All" : "Custom"}');
    }

    // Determine integration type for user feedback
    final integrationTypes = _selectedCalendars.map((cal) => cal.source).toSet();
    final integrationType = integrationTypes.length == 1 
        ? integrationTypes.first.toString().split('.').last.toUpperCase()
        : 'Multiple';

    // Save selected calendars and wait for backend confirmation
    try {
      
      print("🔄 [CalendarSettings] Starting calendar integration...");
      
      final saveResult = await CalendarSyncManager().saveSelectedCalendars(
        userId: widget.userId,
        email: widget.email,
        selectedCalendars: _selectedCalendars,
      );
      
      if (saveResult.success) {
        print("✅ [CalendarSettings] Backend confirmed successful connection");
        
        // Show sync started notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('$integrationType calendar sync in progress...'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Navigate to agenda after backend confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Agenda(
              calendars: _selectedCalendars,
              userId: widget.userId,
              email: widget.email,
              syncInProgress: true,
              syncIntegrationType: integrationType,
            ),
          ),
        );
        
        // Start monitoring sync progress in background
        _monitorSyncProgress(integrationType);
        
      } else {
        throw Exception(saveResult.error ?? 'Unknown error during calendar save');
      }
      
    } catch (e) {
      print("❌ [CalendarSettings] Failed to save selected calendars: $e");
      
      setState(() {
        _isSaving = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect $integrationType calendar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _monitorSyncProgress(String integrationType) {
    // TODO: Implement progress monitoring via polling or websockets
    // For now, show completion message after estimated time
    Future.delayed(Duration(seconds: 20), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Text('$integrationType calendar sync completed!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building CalendarSettings with:");
    print("- Calendars count: ${widget.calendars.length}");
    print("- User ID: ${widget.userId}");
    print("- Email: ${widget.email}");

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: CustomAppBar(),
      body: widget.calendars.isEmpty
          ? Center(child: Text("No calendars found"))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 50.0),
                      child: Text(
                        "Choose what you'd like to import",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        "Start and end time, identificators and timezone always get imported for the selected calendars",
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        children: [
                          Row(
                            children: List.generate(
                              widget.calendars.length,
                              (index) => Container(
                                width: mediaQuery.size.width * 0.25,
                                child: _buildCalendarSection(index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _navigateToAgenda,
                        child: Text('Save',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension ListExtension<T> on List<T> {
  List<List<T>> chunked(int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }
}