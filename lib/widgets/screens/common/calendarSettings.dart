import 'package:flutter/material.dart';
import 'package:timelyst_flutter/widgets/screens/common/agenda.dart';
import '../../../models/calendars.dart';
import '../../../services/googleIntegration/calendarSyncManager.dart';
import '../../shared/customAppbar.dart';
import '../../shared/categories.dart';
import '../../responsive/responsive_helper.dart';
import '../../responsive/responsive_button.dart';

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
  final Duration _fadeDuration = const Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.generate(
      widget.calendars.length,
      (index) => widget.calendars[index].preferences.category ?? '',
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
    final importSettings = calendar.preferences.importSettings;
    final isSelected = importSettings.importAll ||
        importSettings.importSubject ||
        importSettings.importBody ||
        importSettings.importConferenceInfo ||
        importSettings.importOrganizer ||
        importSettings.importRecipients;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Column(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Calendar title header
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                // Leading checkbox to select calendar for import
                Checkbox(
                  value: calendar.preferences.importSettings.importAll ||
                      calendar.preferences.importSettings.importSubject ||
                      calendar.preferences.importSettings.importBody ||
                      calendar
                          .preferences.importSettings.importConferenceInfo ||
                      calendar.preferences.importSettings.importOrganizer ||
                      calendar.preferences.importSettings.importRecipients,
                  onChanged: (checked) {
                    final isChecked = checked ?? false;
                    setState(() {
                      if (isChecked) {
                        // mark calendar as selected: default to Subject import only
                        final updated = calendar.copyWith(
                          preferences: calendar.preferences.copyWith(
                            importSettings:
                                calendar.preferences.importSettings.copyWith(
                              importAll: false,
                              importSubject: true,
                              importBody: false,
                              importConferenceInfo: false,
                              importOrganizer: false,
                              importRecipients: false,
                            ),
                            category: calendar.preferences.category ?? '',
                          ),
                        );
                        widget.calendars[index] = updated;
                        _selectedCategories[index] =
                            updated.preferences.category ?? '';
                      } else {
                        // unselect: clear all import flags and category
                        final updated = calendar.copyWith(
                          preferences: calendar.preferences.copyWith(
                            importSettings:
                                calendar.preferences.importSettings.copyWith(
                              importAll: false,
                              importSubject: false,
                              importBody: false,
                              importConferenceInfo: false,
                              importOrganizer: false,
                              importRecipients: false,
                            ),
                            category: null,
                          ),
                        );
                        widget.calendars[index] = updated;
                        _selectedCategories[index] = '';
                      }
                    });
                  },
                ),

                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: _fadeDuration,
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                      color: isSelected
                          ? Theme.of(context).textTheme.titleMedium?.color
                          : Theme.of(context).disabledColor,
                    ),
                    child: Text(calendar.metadata.title),
                  ),
                ),
              ],
            ),
          ),
          // Animated fade and disable import settings when calendar not selected
          // Category selection should work independently of import settings when calendar is selected
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.45,
            duration: _fadeDuration,
            curve: Curves.easeInOut,
            child: Column(
              children: [
                // Import settings are disabled when calendar is not selected
                AbsorbPointer(
                  absorbing: !isSelected,
                  child: _buildCalendarImportSettings(index),
                ),
                const SizedBox(height: 12),
                // Category selection is disabled when calendar is not selected
                AbsorbPointer(
                  absorbing: !isSelected,
                  child: _buildCategorySelection(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarImportSettings(int index) {
    final calendar = widget.calendars[index];
    final importSettings = calendar.preferences.importSettings;
    final noneSelected = !importSettings.importAll &&
        !(importSettings.importSubject ||
            importSettings.importBody ||
            importSettings.importConferenceInfo ||
            importSettings.importOrganizer ||
            importSettings.importRecipients);
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
                          importSettings:
                              calendar.preferences.importSettings.copyWith(
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
                      print(
                          '  📋 Import All: ${updatedCalendar.preferences.importSettings.importAll}');
                      print(
                          '  📋 Import Subject: ${updatedCalendar.preferences.importSettings.importSubject}');
                      print(
                          '  📋 Import Body: ${updatedCalendar.preferences.importSettings.importBody}');
                    });
                  },
                ),

                // 'None' Checkbox - explicit choice to import nothing
                _buildCheckbox(
                  'None',
                  noneSelected,
                  importSettings.importAll
                      ? null
                      : (value) {
                          if (value == null || value == false) return;
                          // When None is checked, clear all individual options but keep category
                          setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
                                  importAll: false,
                                  importSubject: false,
                                  importBody: false,
                                  importConferenceInfo: false,
                                  importOrganizer: false,
                                  importRecipients: false,
                                ),
                                // Keep the existing category when None is selected
                                category: calendar.preferences.category ?? '',
                              ),
                            );
                            widget.calendars[index] = updatedCalendar;
                            // Ensure the selected category is maintained
                            _selectedCategories[index] =
                                updatedCalendar.preferences.category ?? 'Work';
                          });
                        },
                ),
                // Hint explaining 'None' semantics
                if (noneSelected || !importSettings.importAll)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      "None: only start and end times and category will be imported",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),

                // Individual Checkboxes
                _buildCheckbox(
                  'Subject',
                  importSettings.importSubject,
                  // disable individual checkboxes if "All" is selected or "None" is selected
                  (importSettings.importAll || noneSelected)
                      ? null
                      : (value) => setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
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
                  (importSettings.importAll || noneSelected)
                      ? null
                      : (value) => setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
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
                  (importSettings.importAll || noneSelected)
                      ? null
                      : (value) => setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
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
                  (importSettings.importAll || noneSelected)
                      ? null
                      : (value) => setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
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
                  (importSettings.importAll || noneSelected)
                      ? null
                      : (value) => setState(() {
                            final updatedCalendar = calendar.copyWith(
                              preferences: calendar.preferences.copyWith(
                                importSettings: calendar
                                    .preferences.importSettings
                                    .copyWith(
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
    final calendarIndex = widget.calendars
        .indexWhere((c) => c.providerCalendarId == calendar.providerCalendarId);
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
    print('📋 [CalendarSettings] STATE CHECK - All calendars before filtering:');
    for (int i = 0; i < widget.calendars.length; i++) {
      final calendar = widget.calendars[i];
      final importSettings = calendar.preferences.importSettings;
      print('📅 [UI STATE] Calendar $i: "${calendar.metadata.title}"');
      print('  📊 Source: ${calendar.source}');
      print('  🔗 Provider ID: ${calendar.providerCalendarId}');
      print('  🏷️ UI Category (_selectedCategories[$i]): "${_selectedCategories[i]}"');
      print('  🏷️ Model Category (calendar.preferences.category): "${calendar.preferences.category}"');
      print('  ✅ Import All: ${importSettings.importAll}');
      print('  📝 Import Subject: ${importSettings.importSubject}');
      print('  📄 Import Body: ${importSettings.importBody}');
      print('  📞 Import Conference: ${importSettings.importConferenceInfo}');
      print('  👥 Import Organizer: ${importSettings.importOrganizer}');
      print('  📮 Import Recipients: ${importSettings.importRecipients}');
      print('  ─────────────────────────────────');
    }

    // Filter out calendars that are not selected
    // A calendar is considered selected if it has any import option enabled OR if it has a category set
    // This handles both cases: when specific metadata is selected AND when "None" is selected (but category is set)
    final _selectedCalendars = widget.calendars.where((calendar) {
      final importSettings = calendar.preferences.importSettings;
      final hasAnyImportOption = importSettings.importAll ||
          importSettings.importSubject ||
          importSettings.importBody ||
          importSettings.importConferenceInfo ||
          importSettings.importOrganizer ||
          importSettings.importRecipients;

      // A calendar is selected if it has any import option OR if it has a category set
      // This ensures calendars with "None" selected but with a category are still included
      return hasAnyImportOption || calendar.preferences.category != null;
    }).toList();

    // Enhanced logging: Show details of each selected calendar
    print('📋 [CalendarSettings] SELECTED CALENDARS - After filtering ${_selectedCalendars.length} calendars:');
    for (int i = 0; i < _selectedCalendars.length; i++) {
      final calendar = _selectedCalendars[i];
      print('📅 [SELECTED] Calendar $i: "${calendar.metadata.title}"');
      print('  📊 Source: ${calendar.source}');
      print('  🔗 Provider ID: ${calendar.providerCalendarId}');
      print('  🏷️ Final Category: "${calendar.preferences.category}"');
      print('  ✅ Import All: ${calendar.preferences.importSettings.importAll}');
      print('  📝 Import Subject: ${calendar.preferences.importSettings.importSubject}');
      print('  🔄 Will be sent to: ${calendar.source.name.toUpperCase()} service');
      print('  ─────────────────────────────────');
    }

    // Determine integration type for user feedback
    final integrationTypes =
        _selectedCalendars.map((cal) => cal.source).toSet();
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
          print('🔍 [CalendarSettings] SHOWING SYNC IN PROGRESS SNACKBAR');
          // Clear any existing snackbars before showing new one
          ScaffoldMessenger.of(context).clearSnackBars();
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
        throw Exception(
            saveResult.error ?? 'Unknown error during calendar save');
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
            content: Text(
                'Failed to connect $integrationType calendar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _monitorSyncProgress(String integrationType) {
    // NOTE: Removed delayed completion snackbar since Agenda screen handles sync completion
    // The Agenda screen will show the appropriate completion message based on actual sync progress
    print(
        '🔍 [CalendarSettings] SKIPPING DELAYED COMPLETION SNACKBAR - Agenda will handle completion');
  }

  @override
  Widget build(BuildContext context) {
    print("Building CalendarSettings with:");
    print("- Calendars count: ${widget.calendars.length}");
    print("- User ID: ${widget.userId}");
    print("- Email: ${widget.email}");

    // Use existing responsive system
    final screenSize = ResponsiveHelper.getScreenSize(context);

    // Responsive calendar grid configuration using your system
    final crossAxisCount = ResponsiveHelper.getValue(
      context,
      mobile: 1,
      tablet: 3,
      desktop: 4,
    );

    final maxCardWidth = ResponsiveHelper.getValue(
      context,
      mobile: double.infinity,
      tablet: 280.0,
      desktop: 300.0,
    );

    final horizontalPadding = ResponsiveHelper.getValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );

    final titleFontSize = ResponsiveHelper.getValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    final bodyFontSize = ResponsiveHelper.getValue(
      context,
      mobile: 14.0,
      tablet: 15.0,
      desktop: 16.0,
    );

    return Scaffold(
      appBar: CustomAppBar(),
      body: widget.calendars.isEmpty
          ? Center(child: Text("No calendars found"))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      // Header section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          children: [
                            Text(
                              "Choose what you'd like to import",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: titleFontSize,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Container(
                              constraints: BoxConstraints(maxWidth: 600),
                              child: Text(
                                "Start and end time, identificators and timezone always get imported for the selected calendars",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: bodyFontSize,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Responsive calendar grid using your system
                      if (ResponsiveHelper.isDesktop(context) ||
                          ResponsiveHelper.isTablet(context))
                        // Grid layout for larger screens
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final itemWidth = (maxWidth / crossAxisCount) - 16;
                            final finalItemWidth = itemWidth > maxCardWidth
                                ? maxCardWidth
                                : itemWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                widget.calendars.length,
                                (index) => Container(
                                  width: finalItemWidth,
                                  child: _buildCalendarSection(index),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        // Single column layout for mobile
                        Column(
                          children: List.generate(
                            widget.calendars.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 500),
                                child: _buildCalendarSection(index),
                              ),
                            ),
                          ),
                        ),

                      // Save button using ResponsiveButton
                      Padding(
                        padding: EdgeInsets.only(
                          top: 32.0,
                          bottom: 16.0,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: ResponsiveHelper.getValue(
                              context,
                              mobile: double.infinity,
                              tablet: 400.0,
                              desktop: 300.0,
                            ),
                          ),
                          width: double.infinity,
                          child: ResponsiveButton(
                            text: 'Save',
                            onPressed: _navigateToAgenda,
                            type: ButtonType.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
