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

  Widget _buildCalendarSection(int index) {
    final calendar = widget.calendars[index];
    return ExpansionTile(
      key: ValueKey(calendar.id),
      title: Text(calendar.title),
      children: [
        _buildImportSettings(index),
        _buildCategorySelection(index),
      ],
    );
  }

  Widget _buildImportSettings(int index) {
    return Column(
      children: [
        _buildSectionHeader('Information to import'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              _buildCheckbox(
                'All',
                _importSettingsList[index].all,
                (value) => setState(
                    () => _importSettingsList[index].all = value ?? false),
              ),
              _buildCheckbox(
                'Subject',
                _importSettingsList[index].all,
                (value) => setState(
                    () => _importSettingsList[index].all = value ?? false),
              ),
              _buildCheckbox(
                'Description',
                _importSettingsList[index].all,
                (value) => setState(
                    () => _importSettingsList[index].all = value ?? false),
              ),
              _buildCheckbox(
                'Organizer',
                _importSettingsList[index].all,
                (value) => setState(
                    () => _importSettingsList[index].all = value ?? false),
              ),
              _buildCheckbox(
                'Recipients',
                _importSettingsList[index].all,
                (value) => setState(
                    () => _importSettingsList[index].all = value ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(int index) {
    return Column(
      children: [
        _buildSectionHeader('Assign Category'),
        ..._buildCategoryRows(index),
      ],
    );
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

    return Scaffold(
      appBar: CustomAppBar(),
      body: widget.calendars.isEmpty
          ? Center(child: Text("No calendars found"))
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.calendars.length,
                      itemBuilder: (context, index) =>
                          _buildCalendarSection(index),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _navigateToAgenda,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: CustomAppBar(),
  //     body: SafeArea(
  //       child: SingleChildScrollView(
  //         child: ConstrainedBox(
  //           constraints: BoxConstraints(
  //             minHeight: MediaQuery.of(context).size.height,
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 const SizedBox(height: 20),
  //                 Text(
  //                   'Choose what you’d like to import for',
  //                   style: Theme.of(context).textTheme.titleMedium,
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 10),
  //                 Text(
  //                   'Maria Donosova calendar',
  //                   style: Theme.of(context).textTheme.titleMedium,
  //                 ),
  //                 const SizedBox(height: 10),
  //                 _buildSectionHeader('Information that will be imported'),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
  //                   child: Column(
  //                     children: [
  //                       _buildCheckbox(
  //                         'All',
  //                         _importSettings.all,
  //                         (value) => setState(
  //                             () => _importSettings.all = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Subject',
  //                         _importSettings.subject,
  //                         (value) => setState(
  //                             () => _importSettings.subject = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Body',
  //                         _importSettings.body,
  //                         (value) => setState(
  //                             () => _importSettings.body = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Attachments',
  //                         _importSettings.attachments,
  //                         (value) => setState(() =>
  //                             _importSettings.attachments = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Conference Info',
  //                         _importSettings.conferenceInfo,
  //                         (value) => setState(() =>
  //                             _importSettings.conferenceInfo = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Organizer',
  //                         _importSettings.organizer,
  //                         (value) => setState(
  //                             () => _importSettings.organizer = value ?? false),
  //                       ),
  //                       _buildCheckbox(
  //                         'Recipients Info',
  //                         _importSettings.recipients,
  //                         (value) => setState(() =>
  //                             _importSettings.recipients = value ?? false),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 30),
  //                 _buildSectionHeader('Assign Category'),
  //                 ..._buildCategoryRows(),
  //                 const SizedBox(height: 40),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Theme.of(context).primaryColor,
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                   ),
  //                   onPressed: _navigateToAgenda,
  //                   child: const Text('Next'),
  //                 ),
  //                 const SizedBox(height: 20),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
