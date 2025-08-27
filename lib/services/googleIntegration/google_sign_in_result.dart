class GoogleSignInResult {
  final String userId;
  final String email;

  GoogleSignInResult({required this.userId, required this.email});
}

class GoogleSignInException implements Exception {
  final String message;

  GoogleSignInException(this.message);

  @override
  String toString() => 'GoogleSignInException: $message';
}
