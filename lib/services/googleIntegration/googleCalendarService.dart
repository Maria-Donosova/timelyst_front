import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/envVarConfig.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../models/calendars.dart';

class GoogleCalendarService {
  final AuthService _authService;
  final String _baseUrl = Config.backendFetchGoogleCalendars;
  String? _cachedToken;

  // Token initialization
  Future<void> initialize() async {
    _cachedToken = await _authService.getAuthToken();
  }

  GoogleCalendarService({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Fetches the initial list of Google Calendars using a one-time auth code.
  Future<List<Calendar>> firstCalendarFetch({
    required String authCode,
  }) async {
    print(
        'Performing first calendar fetch with auth code in GoogleCalendarService');
    try {
      final token = await _getValidToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Token fetch timeout'),
      );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Client-Version': '1.0.0',
        'X-Requested-With': 'XMLHttpRequest',
      };

      final response = await http
          .post(
            Uri.parse(
                '$_baseUrl/calendars/list'), // Using the existing endpoint
            headers: headers,
            body: json.encode({
              'authCode': authCode, // Sending authCode as requested
            }),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          // Assuming the backend returns the list under a 'calendars' key
          final calendarsData = decoded['data']['calendars'] as List;
          return calendarsData
              .map((json) => Calendar.fromLegacyJson(json))
              .toList();
        } else {
          final message =
              decoded['message'] ?? 'Failed to fetch initial calendars';
          throw Exception(message is String ? message : json.encode(message));
        }
      } else {
        throw HttpException(
          'Failed to load calendars: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout during first calendar fetch: $e');
      rethrow;
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      print('Unexpected error during first fetch: $e');
      rethrow;
    }
  }

  // Gets calendar changes since last sync (delta sync)
  Future<CalendarDelta> fetchCalendarChanges({
    required String userId,
    required String email,
    required String syncToken,
    int maxResults = 250,
  }) async {
    print(
        'Fetching calendar changes $userId $email in fetchCalendarChanges google calendar service');
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

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return CalendarDelta.fromJson(decoded['data']);
        } else {
          throw Exception(
              decoded['message'] ?? 'Failed to fetch calendar delta');
        }
      } else {
        throw HttpException(
          'Failed to load calendar changes: ${response.statusCode}',
        );
      }
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
    print(
        'Saving selected calendars $userId $email in saveCalendarsBatch google calendar service');
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
    if (_cachedToken == null) {
      _cachedToken = await _authService.getAuthToken();
    }
    return _cachedToken!;
  }

  Map<String, String> _buildHeaders(String token) {
    print('Building headers in _buildHeaders google calendar service');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Client-Version': '1.0.0', // For API versioning
    };
  }

  void _handleBatchResponse(http.Response response) {
    print(
        'Handling batch response in _handleBatchResponse google calendar service');
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
    print('Handling error in _handleError google calendar service');
    if (error is http.ClientException) {
      return Exception('Network error while $operation: ${error.message}');
    }
    return Exception('Error $operation: ${error.toString()}');
  }

  Future fetchCalendarsPage({required userId, required email}) async {}
}
