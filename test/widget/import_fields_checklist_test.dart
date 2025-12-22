import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/import_settings.dart';
import 'package:timelyst_flutter/widgets/settings/import_fields_checklist.dart';

void main() {
  testWidgets('ImportFieldsChecklist toggles Custom/All/None', (WidgetTester tester) async {
    ImportSettings settings = ImportSettings(level: ImportLevel.custom, fields: ['subject']);
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return ImportFieldsChecklist(
              settings: settings,
              onChanged: (newSettings) {
                setState(() {
                  settings = newSettings;
                });
              },
            );
          },
        ),
      ),
    ));

    // Initially custom, subject should be checked
    // Checkboxes order: All, None, Subject, description, ...
    expect(find.byType(Checkbox), findsWidgets);
    
    // Click 'All'
    await tester.tap(find.text('All'));
    await tester.pump();
    expect(settings.level, ImportLevel.all);

    // Click 'None'
    await tester.tap(find.text('None'));
    await tester.pump();
    expect(settings.level, ImportLevel.none);
  });
}
