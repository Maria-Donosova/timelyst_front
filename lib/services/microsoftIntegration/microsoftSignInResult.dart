import '../../models/calendars.dart';

class MicrosoftSignInResult {
  final String? userId;
  final String? email;
  final String? authCode;
  final List<Calendar>? calendars;

  MicrosoftSignInResult({
    this.userId,
    this.email,
    this.authCode,
    this.calendars,
  });

  @override
  String toString() {
    return 'MicrosoftSignInResult(userId: $userId, email: $email, authCode: ${authCode?.substring(0, 10)}..., calendars: ${calendars?.length})';
  }
}