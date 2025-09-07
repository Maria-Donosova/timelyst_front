import '../../models/calendars.dart';

class GoogleSignInResult {
  final String userId;
  final String email;
  final String? authCode;
  final List<Calendar>? calendars;

  GoogleSignInResult(
      {required this.userId, 
      required this.email, 
      this.authCode,
      this.calendars});
}

class GoogleSignInException implements Exception {
  final String message;

  GoogleSignInException(this.message);

  @override
  String toString() => 'GoogleSignInException: $message';
}
