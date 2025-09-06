class GoogleSignInResult {
  final String userId;
  final String email;
  final String? authCode;

  GoogleSignInResult(
      {required this.userId, required this.email, this.authCode});
}

class GoogleSignInException implements Exception {
  final String message;

  GoogleSignInException(this.message);

  @override
  String toString() => 'GoogleSignInException: $message';
}
