class CalendarException implements Exception {
  final String message;
  final int? statusCode;

  CalendarException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class CalendarNotFoundException extends CalendarException {
  CalendarNotFoundException(String message) : super(message, 404);
}

class UnauthorizedException extends CalendarException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message, 401);
}

class ValidationException extends CalendarException {
  final Map<String, dynamic>? errors;
  
  ValidationException(String message, [this.errors]) : super(message, 400);
}
