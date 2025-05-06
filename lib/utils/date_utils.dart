class DateTimeUtils {
  // Parse any date format (ISO string or timestamp)
  static DateTime parseAnyFormat(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    try {
      // Check if it's a numeric timestamp (milliseconds since epoch)
      if (dateValue is String && dateValue.contains(RegExp(r'^\d+$'))) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
      } 
      // Otherwise try parsing as ISO string
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now(); // Fallback
    }
  }
  
  // Format date to ISO string for sending to API
  static String formatForApi(DateTime date) {
    return date.toIso8601String();
  }
}