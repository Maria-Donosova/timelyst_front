import '../../models/calendars.dart';

class AppleSignInResult {
  final String? userId;
  final String? email;
  final String? authCode;
  final List<Calendar>? calendars;

  AppleSignInResult({
    this.userId,
    this.email,
    this.authCode,
    this.calendars,
  });

  @override
  String toString() {
    return 'AppleSignInResult(userId: $userId, email: $email, authCode: ${authCode?.substring(0, 10)}..., calendars: ${calendars?.length})';
  }
}