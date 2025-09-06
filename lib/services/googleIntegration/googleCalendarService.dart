import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/envVarConfig.dart';
import 'package:timelyst_flutter/services/authService.dart';
import '../../utils/apiClient.dart';
import '../../models/calendars.dart';

class GoogleCalendarService {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  final String _baseUrl = Config.backendFetchGoogleCalendars;
  String? _cachedToken;

  // Token initialization
  Future<void> initialize() async {
    _cachedToken = await _authService.getAuthToken();
  }

  GoogleCalendarService({AuthService? authService, ApiClient? apiClient})
      : _authService = authService ?? AuthService(),
        _apiClient = apiClient ?? ApiClient();

  /// Fetches the initial list of Google Calendars using a one-time auth code.
  Future<List<Calendar>> firstCalendarFetch({
    required String authCode,
    required String email,
  }) async {
    // logger.i(
    //     'Performing first calendar fetch with auth code in GoogleCalendarService');
    try {
      final response = await _apiClient.post(
        '$_baseUrl/calendars/list',
        body: {
          'authCode': authCode,
          'email': email,
        },
        token: await _authService.getAuthToken(),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['calendars'] != null) {
          // Assuming the backend returns the list under a 'calendars' key
          final calendarsData = decoded['calendars'] as List;
          return calendarsData
              .map((json) => Calendar.fromGoogleJson(json))
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
      // logger.e('Timeout during first calendar fetch: $e');
      rethrow;
    } on http.ClientException catch (e) {
      // logger.e('Network error: $e');
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      // logger.e('Unexpected error during first fetch: $e');
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
    // logger.i(
    //     'Fetching calendar changes $userId $email in fetchCalendarChanges google calendar service');
    try {
      final response = await _apiClient.post(
        '$_baseUrl/calendars/delta',
        body: {
          'userId': userId,
          'email': email,
          'syncToken': syncToken,
          'maxResults': maxResults,
        },
        token: await _authService.getAuthToken(),
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
    // logger.i(
    //     'Saving selected calendars $userId $email in saveCalendarsBatch google calendar service');
    try {
      final response = await _apiClient.post(
        Config.backendSaveSelectedGoogleCalendars,
        body: {
          'user': userId,
          'email': email,
          'calendars': calendars.map((c) => c.toJson(email: email)).toList(),
          'batchSize': calendars.length,
        },
        token: await _authService.getAuthToken(),
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

  void _handleBatchResponse(http.Response response) {
    // logger.i(
    //     'Handling batch response in _handleBatchResponse google calendar service');
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
    // logger.i('Handling error in _handleError google calendar service');
    if (error is http.ClientException) {
      return Exception('Network error while $operation: ${error.message}');
    }
    return Exception('Error $operation: ${error.toString()}');
  }

  Future<CalendarPage> fetchCalendarsPage({
    required String userId,
    required String email,
    String? pageToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_baseUrl/calendars/list',
        body: {
          'userId': userId,
          'email': email,
          'pageToken': pageToken,
        },
        token: await _authService.getAuthToken(),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return CalendarPage.fromJson(decoded['data']);
        } else {
          final message =
              decoded['message'] ?? 'Failed to fetch calendars page';
          throw Exception(message is String ? message : json.encode(message));
        }
      } else {
        throw HttpException(
          'Failed to load calendars page: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      rethrow;
    } on http.ClientException catch (e) {
      throw Exception('Network error. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
