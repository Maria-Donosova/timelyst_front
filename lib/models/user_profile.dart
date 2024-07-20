class UserProfile {
  final String name;
  final String email;
  final List<String> accounts;
  final List<String> calendars;

  UserProfile(
      {required this.name,
      required this.email,
      required this.accounts,
      required this.calendars});
}
