import 'package:flutter/material.dart';
import 'package:timelyst_flutter/screens/common/agenda.dart';
import '../../models/calendars.dart';
import '../../apis/googleIntegration/googleOrchestrator.dart';
import '../../widgets/shared/customAppbar.dart';
import '../../widgets/shared/categories.dart';

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
                      calendar.preferences.importSettings =
                          calendar.preferences.importSettings.copyWith(
                        importAll: newValue,
                        importSubject: newValue,
                        importBody: newValue,
                        importConferenceInfo: newValue,
                        importOrganizer: newValue,
                        importRecipients: newValue,
                      );
                    });
                  },
                ),

                // Individual Checkboxes
                _buildCheckbox(
                  'Subject',
                  importSettings.importSubject,
                  (value) => setState(() {
                    calendar.preferences.importSettings =
                        calendar.preferences.importSettings.copyWith(
                      importSubject: value ?? false,
                    );
                    _updateAllCheckboxState(calendar);
                  }),
                ),
                _buildCheckbox(
                  'Description',
                  importSettings.importBody,
                  (value) => setState(() {
                    calendar.preferences.importSettings =
                        calendar.preferences.importSettings.copyWith(
                      importBody: value ?? false,
                    );
                    _updateAllCheckboxState(calendar);
                  }),
                ),
                _buildCheckbox(
                  'Conference Info',
                  importSettings.importConferenceInfo,
                  (value) => setState(() {
                    calendar.preferences.importSettings =
                        calendar.preferences.importSettings.copyWith(
                      importConferenceInfo: value ?? false,
                    );
                    _updateAllCheckboxState(calendar);
                  }),
                ),
                _buildCheckbox(
                  'Organizer',
                  importSettings.importOrganizer,
                  (value) => setState(() {
                    calendar.preferences.importSettings =
                        calendar.preferences.importSettings.copyWith(
                      importOrganizer: value ?? false,
                    );
                    _updateAllCheckboxState(calendar);
                  }),
                ),
                _buildCheckbox(
                  'Recipients',
                  importSettings.importRecipients,
                  (value) => setState(() {
                    calendar.preferences.importSettings =
                        importSettings.copyWith(
                      importRecipients: value ?? false,
                    );
                    _updateAllCheckboxState(calendar);
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

    setState(() {
      calendar.preferences.importSettings =
          calendar.preferences.importSettings.copyWith(
        importAll: allChecked,
      );
    });
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
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

  Future<void> _navigateToAgenda() async {
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

    // Save selected calendars using the orchestrator
    try {
      await GoogleOrchestrator().saveSelectedCalendars(
        widget.userId,
        widget.email,
        _selectedCalendars,
      );
      print("Selected calendars saved successfully.");

      // Navigate to the Agenda screen only if saving is successful
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Agenda(
            calendars: _selectedCalendars,
            userId: widget.userId,
            email: widget.email,
          ),
        ),
      );
    } catch (e) {
      print("Failed to save selected calendars: $e");

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save calendars: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'agenda.dart';
// import '../../models/calendars.dart';
// import '../../services/googleIntegration/googleOrchestrator.dart';
// import '../../widgets/shared/customAppbar.dart';
// import '../../widgets/shared/categories.dart';

// class CalendarSettings extends StatefulWidget {
//   final List<Calendar> calendars;
//   final String userId;
//   final String email;

//   const CalendarSettings({
//     Key? key,
//     required this.calendars,
//     required this.userId,
//     required this.email,
//   }) : super(key: key);

//   static const routeName = '/calendarSettings';

//   @override
//   State<CalendarSettings> createState() => _CalendarSettingsState();
// }

// class _CalendarSettingsState extends State<CalendarSettings> {
//   late List<String> _selectedCategories;

//   @override
//   void initState() {
//     super.initState();
//     _selectedCategories = List.generate(
//       widget.calendars.length,
//       (index) => widget.calendars[index].preferences.category ?? 'Work',
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Container(
//       color: Theme.of(context).colorScheme.secondary,
//       padding: const EdgeInsets.all(8),
//       margin: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Theme.of(context).colorScheme.onSecondary,
//           fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarSection(int index) {
//     final calendar = widget.calendars[index];
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
//       child: Column(
//         key: ValueKey(calendar.id),
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Calendar title header
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               calendar.title,
//               style: TextStyle(
//                 fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
//               ),
//             ),
//           ),
//           _buildCalendarImportSettings(index),
//           const SizedBox(height: 12),
//           _buildCategorySelection(index),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendarImportSettings(int index) {
//     final calendar = widget.calendars[index];
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildSectionHeader('What would you like to import?'),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Column(
//               children: [
//                 // 'All' Checkbox
//                 _buildCheckbox(
//                   'All',
//                   calendar.importAll,
//                   (value) {
//                     bool newValue = value ?? false;
//                     setState(() {
//                       calendar.importAll = newValue;
//                       calendar.importSubject = newValue;
//                       calendar.importBody = newValue;
//                       calendar.importConferenceInfo = newValue;
//                       calendar.importOrganizer = newValue;
//                       calendar.importRecipients = newValue;
//                     });
//                   },
//                 ),

//                 // Individual Checkboxes
//                 _buildCheckbox(
//                   'Subject',
//                   calendar.importSubject,
//                   (value) => setState(() {
//                     calendar.importSubject = value ?? false;
//                     _updateAllCheckboxState(calendar);
//                   }),
//                 ),
//                 _buildCheckbox(
//                   'Description',
//                   calendar.importBody,
//                   (value) => setState(() {
//                     calendar.importBody = value ?? false;
//                     _updateAllCheckboxState(calendar);
//                   }),
//                 ),
//                 _buildCheckbox(
//                   'Conference Info',
//                   calendar.importConferenceInfo,
//                   (value) => setState(() {
//                     calendar.importConferenceInfo = value ?? false;
//                     _updateAllCheckboxState(calendar);
//                   }),
//                 ),
//                 _buildCheckbox(
//                   'Organizer',
//                   calendar.importOrganizer,
//                   (value) => setState(() {
//                     calendar.importOrganizer = value ?? false;
//                     _updateAllCheckboxState(calendar);
//                   }),
//                 ),
//                 _buildCheckbox(
//                   'Recipients',
//                   calendar.importRecipients,
//                   (value) => setState(() {
//                     calendar.importRecipients = value ?? false;
//                     _updateAllCheckboxState(calendar);
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to update 'All' checkbox state
//   void _updateAllCheckboxState(Calendar calendar) {
//     bool allChecked = calendar.importSubject &&
//         calendar.importBody &&
//         calendar.importConferenceInfo &&
//         calendar.importOrganizer &&
//         calendar.importRecipients;
//     calendar.importAll = allChecked;
//   }

//   Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ),
//         Checkbox(
//           checkColor: Colors.grey[800],
//           activeColor: const Color.fromRGBO(207, 204, 215, 100),
//           visualDensity: VisualDensity.compact,
//           value: value,
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }

//   Widget _buildCategorySelection(int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildSectionHeader('Assign Category'),
//           ..._buildCategoryRows(index),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildCategoryRows(int index) {
//     return categories.chunked(2).map((rowCategories) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: rowCategories.map((category) {
//           return Container(
//             width: 150,
//             child: RadioListTile<String>(
//               activeColor: catColor(category),
//               fillColor: WidgetStateProperty.all(catColor(category)),
//               dense: true,
//               value: category,
//               groupValue: _selectedCategories[index],
//               title: Text(category),
//               onChanged: (String? value) => setState(() {
//                 _selectedCategories[index] = value!;
//               }),
//             ),
//           );
//         }).toList(),
//       );
//     }).toList();
//   }

//   Future<void> _navigateToAgenda() async {
//     // Filter out calendars that are not selected (no import options enabled)
//     final _selectedCalendars = widget.calendars.where((calendar) {
//       return calendar.importAll ||
//           calendar.importSubject ||
//           calendar.importBody ||
//           calendar.importConferenceInfo ||
//           calendar.importOrganizer ||
//           calendar.importRecipients;
//     }).map((calendar) {
//       print(
//           "Category: ${_selectedCategories[widget.calendars.indexOf(calendar)]},");
//       print("Category color: ${calendar.catColor}");
//       return Calendar(
//         user: calendar.user,
//         title: calendar.title,
//         category: _selectedCategories[widget.calendars.indexOf(calendar)],
//         kind: calendar.kind,
//         etag: calendar.etag,
//         id: calendar.id,
//         description: calendar.description,
//         sourceCalendar: calendar.sourceCalendar,
//         timeZone: calendar.timeZone,
//         catColor: calendar.catColor,
//         defaultReminders: calendar.defaultReminders,
//         notificationSettings: calendar.notificationSettings,
//         conferenceProperties: calendar.conferenceProperties,
//         organizer: calendar.organizer,
//         recipients: calendar.recipients,
//         importAll: calendar.importAll,
//         importSubject: calendar.importSubject,
//         importBody: calendar.importBody,
//         importConferenceInfo: calendar.importConferenceInfo,
//         importOrganizer: calendar.importOrganizer,
//         //importRecipients: json['importRecipients'] ?? false,
//         color: 0xFFA4BDFC,
//         isDefault: false,
//         isPrimary: false,
//         type: '',
//       );
//     }).toList();

//     // Save selected calendars using the orchestrator
//     try {
//       await GoogleOrchestrator().saveSelectedCalendars(
//         widget.userId,
//         widget.email,
//         _selectedCalendars,
//       );
//       print("Selected calendars saved successfully.");

//       // Navigate to the Agenda screen only if saving is successful
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Agenda(
//             calendars: _selectedCalendars,
//             userId: widget.userId,
//             email: widget.email,
//           ),
//         ),
//       );
//     } catch (e) {
//       print("Failed to save selected calendars: $e");

//       // Show an error message to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save calendars: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );

//       // Do not navigate to the Agenda screen if there's an error
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Building CalendarSettings with:");
//     print("- Calendars count: ${widget.calendars.length}");
//     print("- User ID: ${widget.userId}");
//     print("- Email: ${widget.email}");

//     final mediaQuery = MediaQuery.of(context);

//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: widget.calendars.isEmpty
//           ? Center(child: Text("No calendars found"))
//           : SafeArea(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 10.0, right: 10.0, top: 50.0),
//                       child: Text(
//                         "Choose what you'd like to import",
//                         style: Theme.of(context).textTheme.titleMedium,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 40.0),
//                       child: Text(
//                         "Start and end time, identificators and timezone always get imported for the selected calendars",
//                         style: Theme.of(context).textTheme.titleSmall,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Wrap(
//                         children: [
//                           Row(
//                             children: List.generate(
//                               widget.calendars.length,
//                               (index) => Container(
//                                 width: mediaQuery.size.width * 0.25,
//                                 child: _buildCalendarSection(index),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:
//                               Theme.of(context).colorScheme.secondary,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         onPressed: _navigateToAgenda,
//                         child: Text('Save',
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSecondary,
//                             )),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// extension ListExtension<T> on List<T> {
//   List<List<T>> chunked(int chunkSize) {
//     List<List<T>> chunks = [];
//     for (var i = 0; i < length; i += chunkSize) {
//       chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
//     }
//     return chunks;
//   }
// }
