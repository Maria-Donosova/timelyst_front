import 'package:flutter/material.dart';
import 'agenda.dart';
import '../../widgets/shared/customAppbar.dart';
import '../../widgets/shared/categories.dart';
import '../../models/calendars.dart';

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

  @override
  State<CalendarSettings> createState() => _CalendarSettingsState();
}

class _CalendarSettingsState extends State<CalendarSettings> {
  late List<ImportSettings> _importSettingsList;
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _importSettingsList = List.generate(
      widget.calendars.length,
      (index) => ImportSettings(),
    );
    _selectedCategories = List.generate(
      widget.calendars.length,
      (index) => widget.calendars[index].category ?? 'Work',
    );
  }

  void _navigateToAgenda() {
    final _selectedCalendars = widget.calendars.asMap().entries.map((entry) {
      final index = entry.key;
      return Calendar(
        user: entry.value.user,
        title: entry.value.title,
        category: _selectedCategories[index],
        // Add other necessary fields from import settings
        // ...
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Agenda(
            // calendars: selectedCalendars,
            // userId: widget.userId,
            // email: widget.email,
            ),
      ),
    );
  }

  // Widget _buildCalendarSection(int index) {
  //   final calendar = widget.calendars[index];
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: ExpansionTile(
  //       key: ValueKey(calendar.id),
  //       title: Text(calendar.title),
  //       children: [
  //         _buildImportSettings(index),
  //         _buildCategorySelection(index),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCalendarSection(int index) {
  //   final calendar = widget.calendars[index];
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       key: ValueKey(calendar.id),
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Calendar title header
  //         Text(
  //           calendar.title,
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),

  //         // Calendar content
  //         _buildImportSettings(index),
  //         const SizedBox(height: 12),
  //         _buildCategorySelection(index),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCalendarSection(int index) {
    final calendar = widget.calendars[index];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        key: ValueKey(calendar.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar title header
          Text(
            calendar.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Calendar content
          _buildImportSettings(index),
          const SizedBox(height: 12),
          _buildCategorySelection(index),
        ],
      ),
    );
  }

  Widget _buildImportSettings(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Information to import'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                // 'All' Checkbox
                _buildCheckbox(
                  'All',
                  _importSettingsList[index].all,
                  (value) {
                    bool newValue = value ?? false;
                    setState(() {
                      _importSettingsList[index].all = newValue;
                      _importSettingsList[index].subject = newValue;
                      _importSettingsList[index].body = newValue;
                      _importSettingsList[index].organizer = newValue;
                      _importSettingsList[index].recipients = newValue;
                    });
                  },
                ),
                // Individual Checkboxes
                _buildCheckbox(
                  'Subject',
                  _importSettingsList[index].subject,
                  (value) => setState(() {
                    _importSettingsList[index].subject = value ?? false;
                    _updateAllCheckboxState(index);
                  }),
                ),
                _buildCheckbox(
                  'Description',
                  _importSettingsList[index].body,
                  (value) => setState(() {
                    _importSettingsList[index].body = value ?? false;
                    _updateAllCheckboxState(index);
                  }),
                ),
                _buildCheckbox(
                  'Organizer',
                  _importSettingsList[index].organizer,
                  (value) => setState(() {
                    _importSettingsList[index].organizer = value ?? false;
                    _updateAllCheckboxState(index);
                  }),
                ),
                _buildCheckbox(
                  'Recipients',
                  _importSettingsList[index].recipients,
                  (value) => setState(() {
                    _importSettingsList[index].recipients = value ?? false;
                    _updateAllCheckboxState(index);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to update 'All' checkbox state
  void _updateAllCheckboxState(int index) {
    bool allChecked = _importSettingsList[index].subject &&
        _importSettingsList[index].body &&
        _importSettingsList[index].organizer &&
        _importSettingsList[index].recipients;
    _importSettingsList[index].all = allChecked;
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
      padding: const EdgeInsets.only(bottom: 8.0),
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
              dense: true,
              value: category,
              groupValue: _selectedCategories[index],
              title: Text(category),
              onChanged: (String? value) => setState(() {
                _selectedCategories[index] = value!;
              }),
            ),
          );
        }).toList(),
      );
    }).toList();
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
                          left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
                      child: Text(
                        "Choose what you'd like to import",
                        style: Theme.of(context).textTheme.titleMedium,
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
                                width: mediaQuery.size.width * 0.3,
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
                        child: Text('Next',
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

  Widget _buildSectionHeader(String title) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
