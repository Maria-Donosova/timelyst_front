import 'package:flutter/material.dart';
import 'agenda.dart';
import '../../widgets/shared/customAppbar.dart';
import '../../widgets/shared/categories.dart';

class ImportSettings {
  bool all;
  bool subject;
  bool body;
  bool attachments;
  bool conferenceInfo;
  bool organizer;
  bool recipients;

  ImportSettings({
    this.all = false,
    this.subject = false,
    this.body = false,
    this.attachments = false,
    this.conferenceInfo = false,
    this.organizer = false,
    this.recipients = false,
  });
}

class CalendarSettings extends StatefulWidget {
  const CalendarSettings({Key? key}) : super(key: key);
  static const routeName = '/landing-page-logo';

  @override
  State<CalendarSettings> createState() => _CalendarSettingsState();
}

class _CalendarSettingsState extends State<CalendarSettings> {
  late ImportSettings _importSettings;
  String _selectedCategory = 'Work';

  @override
  void initState() {
    super.initState();
    _importSettings = ImportSettings();
  }

  void _navigateToAgenda() {
    Navigator.pushNamed(context, Agenda.routeName);
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

  List<Widget> _buildCategoryRows() {
    List<Widget> rows = [];
    for (int i = 0; i < categories.length; i += 2) {
      List<String> rowCategories = [];
      if (i < categories.length) rowCategories.add(categories[i]);
      if (i + 1 < categories.length) rowCategories.add(categories[i + 1]);

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowCategories.map((category) {
            return Container(
              width: 150,
              child: RadioListTile<String>(
                activeColor: catColor(category),
                dense: true,
                value: category,
                groupValue: _selectedCategory,
                title: Text(category),
                onChanged: (String? value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
            );
          }).toList(),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Choose what you’d like to import for',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Maria Donosova calendar',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Information that will be imported'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        _buildCheckbox(
                          'All',
                          _importSettings.all,
                          (value) => setState(
                              () => _importSettings.all = value ?? false),
                        ),
                        _buildCheckbox(
                          'Subject',
                          _importSettings.subject,
                          (value) => setState(
                              () => _importSettings.subject = value ?? false),
                        ),
                        _buildCheckbox(
                          'Body',
                          _importSettings.body,
                          (value) => setState(
                              () => _importSettings.body = value ?? false),
                        ),
                        _buildCheckbox(
                          'Attachments',
                          _importSettings.attachments,
                          (value) => setState(() =>
                              _importSettings.attachments = value ?? false),
                        ),
                        _buildCheckbox(
                          'Conference Info',
                          _importSettings.conferenceInfo,
                          (value) => setState(() =>
                              _importSettings.conferenceInfo = value ?? false),
                        ),
                        _buildCheckbox(
                          'Organizer',
                          _importSettings.organizer,
                          (value) => setState(
                              () => _importSettings.organizer = value ?? false),
                        ),
                        _buildCheckbox(
                          'Recipients Info',
                          _importSettings.recipients,
                          (value) => setState(() =>
                              _importSettings.recipients = value ?? false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader('Assign Category'),
                  ..._buildCategoryRows(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _navigateToAgenda,
                    child: const Text('Next'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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
