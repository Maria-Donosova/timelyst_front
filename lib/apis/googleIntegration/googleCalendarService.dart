import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/envVarConfig.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../models/calendars.dart';

class GoogleCalendarService {
  final AuthService _authService;
  final String _baseUrl = Config.backendFetchGoogleCalendars;

  GoogleCalendarService({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Fetches Google calendars with pagination support
  Future<CalendarPage> fetchCalendarsPage({
    required String userId,
    required String email,
    int pageSize = 50,
    String? pageToken,
    DateTime? modifiedSince,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/calendars/list'),
        headers: _buildHeaders(token),
        body: json.encode({
          'userId': userId,
          'email': email,
          'pageSize': pageSize,
          'pageToken': pageToken,
          'modifiedSince': modifiedSince?.toIso8601String(),
        }),
      );

      return _parseCalendarPage(response);
    } catch (e) {
      throw _handleError('fetching calendars', e);
    }
  }

  /// Gets calendar changes since last sync (delta sync)
  Future<CalendarDelta> fetchCalendarChanges({
    required String userId,
    required String email,
    required String syncToken,
    int maxResults = 250,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/calendars/delta'),
        headers: _buildHeaders(token),
        body: json.encode({
          'userId': userId,
          'email': email,
          'syncToken': syncToken,
          'maxResults': maxResults,
        }),
      );

      return _parseCalendarDelta(response);
    } catch (e) {
      throw _handleError('fetching calendar changes', e);
    }
  }

  /// Saves selected calendars with batch support
  Future<void> saveCalendarsBatch({
    required String userId,
    required String email,
    required List<Calendar> calendars,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/calendars/batch'),
        headers: _buildHeaders(token),
        body: json.encode({
          'user': userId,
          'email': email,
          'calendars': calendars.map((c) => c.toJson(email: email)).toList(),
          'batchSize': calendars.length,
        }),
      );

      _handleBatchResponse(response);
    } catch (e) {
      throw _handleError('saving calendars', e);
    }
  }

  // Helper methods

  Future<String> _getValidToken() async {
    final token = await _authService.getAuthToken();
    if (token == null) {
      throw Exception('Authentication required. Please log in again.');
    }
    return token;
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Client-Version': '1.0.0', // For API versioning
    };
  }

  CalendarPage _parseCalendarPage(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load calendars: ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);
    return CalendarPage(
      calendars: (jsonResponse['calendars'] as List)
          .map((json) => Calendar.fromJson(json))
          .toList(),
      nextPageToken: jsonResponse['nextPageToken'],
      hasMore: jsonResponse['hasMore'] ?? false,
      syncToken: jsonResponse['syncToken'],
      totalItems: jsonResponse['totalItems'] ?? 0,
    );
  }

  CalendarDelta _parseCalendarDelta(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load calendar changes: ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);
    return CalendarDelta(
      changes: (jsonResponse['changes'] as List)
          .map((json) => Calendar.fromJson(json))
          .toList(),
      deletedCalendarIds:
          (jsonResponse['deleted'] as List?)?.cast<String>() ?? [],
      newSyncToken: jsonResponse['syncToken'],
      hasMoreChanges: jsonResponse['hasMore'] ?? false,
    );
  }

  void _handleBatchResponse(http.Response response) {
    if (response.statusCode != 200) {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['message'] ??
            'Failed to save calendars: ${response.statusCode}',
      );
    }

    // Handle partial success cases if needed
    final responseBody = json.decode(response.body);
    if (responseBody['failedOperations'] != null &&
        (responseBody['failedOperations'] as List).isNotEmpty) {
      throw Exception('Partial failure: ${responseBody['failedOperations']}');
    }
  }

  Exception _handleError(String operation, dynamic error) {
    if (error is http.ClientException) {
      return Exception('Network error while $operation: ${error.message}');
    }
    return Exception('Error $operation: ${error.toString()}');
  }
}

/// Paginated calendar response
class CalendarPage {
  final List<Calendar> calendars;
  final String? nextPageToken;
  final bool hasMore;
  final String? syncToken;
  final int totalItems;

  CalendarPage({
    required this.calendars,
    this.nextPageToken,
    this.hasMore = false,
    this.syncToken,
    this.totalItems = 0,
  });
}

/// Delta sync response for calendar changes
class CalendarDelta {
  final List<Calendar> changes;
  final List<String> deletedCalendarIds;
  final String newSyncToken;
  final bool hasMoreChanges;

  CalendarDelta({
    required this.changes,
    required this.deletedCalendarIds,
    required this.newSyncToken,
    this.hasMoreChanges = false,
  });
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:timelyst_flutter/config/env_variables_config.dart';
// import 'package:timelyst_flutter/services/authService.dart';

// import '../../models/calendars.dart';

// class GoogleCalendarService {
//   // Fetch Google Calendars from the backend
//   Future<List<Calendar>> fetchGoogleCalendars(
//       String userId, String email) async {
//     print("Entering fetchGoogleCalendars");
//     print("userId: $userId");
//     print("email: $email");

//     // Retrieve the JWT token from secure storage
//     final authService = AuthService();
//     final token = await authService.getAuthToken();
//     print("Token: $token");

//     if (token == null) {
//       throw Exception('No JWT token found. Please log in again.');
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(Config.backendFetchGoogleCalendars),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'userId': userId,
//           'email': email,
//         }),
//       );

//       print("Response status code: ${response.statusCode}");
//       print("Response body: ${response.body}");

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = json.decode(response.body);
//         print("Response body (decoded): $responseBody");

//         if (responseBody.containsKey('data') && responseBody['data'] is List) {
//           final List<dynamic> data = responseBody['data'];
//           print("Data: $data");

//           return data.map((calendar) => Calendar.fromJson(calendar)).toList();
//         } else {
//           throw Exception(
//               'Invalid response format: "data" field is missing or not a list');
//         }
//       } else {
//         throw Exception('Failed to load calendars: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching calendars: $e');
//       throw Exception('Error fetching calendars: $e');
//     }
//   }

//   // Save selected calendars to the backend
//   Future<void> saveSelectedCalendars(
//       String userId, googleEmail, List<Calendar> selectedCalendars) async {
//     print("Entering saveSelectedCalendars");
//     print("UserId: $userId");
//     print("Google Email: $googleEmail");

//     // Retrieve the JWT token from secure storage
//     final authService = AuthService();
//     final token = await authService.getAuthToken();
//     print("Token: $token");
//     print(
//         'Selected Calendars JSON: ${selectedCalendars.map((c) => c.toJson(email: googleEmail)).toList()}');

//     if (token == null) {
//       throw Exception('No JWT token found. Please log in again.');
//     }

//     try {
//       print('Sending data to backend:');
//       print('userId: $userId');
//       print('googleEmail: $googleEmail');
//       print(
//           'selectedCalendars: ${selectedCalendars.map((c) => c.toJson(email: googleEmail)).toList()}');

//       final response = await http.post(
//         Uri.parse(Config.backendSaveGoogleCalendars),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization':
//               'Bearer $token', // Include your JWT token for authentication
//         },
//         body: json.encode({
//           'user': userId,
//           'email': googleEmail,
//           'calendars': selectedCalendars
//               .map((calendar) => calendar.toJson(email: googleEmail))
//               .toList(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Calendars saved!');
//       } else {
//         print('Backend error: ${response.body}');
//         throw Exception('Failed to save calendars: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error saving calendars: $e');
//       throw Exception('Error saving calendars: $e');
//     }
//   }
// }
