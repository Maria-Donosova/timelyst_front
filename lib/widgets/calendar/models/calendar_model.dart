//boiler plate code for calendar model

class Calendars {
  String calendarId;
  String calendarSource;
  String calendarName;
  String email;
  String password;
  String category;
  List events;
  DateTime dateImported;
  DateTime dateCreated;
  DateTime dateUpdated;

  Calendars(
      {required this.calendarId,
      required this.calendarSource,
      required this.calendarName,
      required this.email,
      required this.password,
      required this.category,
      this.events = const [],
      DateTime? dateImported,
      DateTime? dateCreated,
      DateTime? dateUpdated})
      : dateImported = dateImported ?? DateTime.now(),
        dateCreated = dateCreated ?? DateTime.now(),
        dateUpdated = dateUpdated ?? DateTime.now();
}
