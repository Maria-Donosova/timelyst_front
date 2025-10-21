import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/calendars.dart';

void main() {
  test('None semantics clears all import flags', () {
    final settings = CalendarImportSettings(
      importAll: false,
      importSubject: true,
      importBody: true,
      importConferenceInfo: true,
      importOrganizer: true,
      importRecipients: true,
    );

    // Simulate selecting 'None' by creating a copy with all false
    final none = settings.copyWith(
      importAll: false,
      importSubject: false,
      importBody: false,
      importConferenceInfo: false,
      importOrganizer: false,
      importRecipients: false,
    );

    expect(none.importAll, isFalse);
    expect(none.importSubject, isFalse);
    expect(none.importBody, isFalse);
    expect(none.importConferenceInfo, isFalse);
    expect(none.importOrganizer, isFalse);
    expect(none.importRecipients, isFalse);
  });
}
