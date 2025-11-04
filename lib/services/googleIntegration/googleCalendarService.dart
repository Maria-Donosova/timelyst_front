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

  // Gets calendar changes since last sync (delta sync)
  Future<CalendarDelta> fetchCalendarChanges({
    required String userId,
    required String email,
    required String syncToken,
    int maxResults = 250,
  }) async {
    print('Entering fetchCalendarChanges');
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
    print(
        'Entered fetchCalendarChanges, preparing to save ${calendars.length} Google calendars');

    // Convert calendars to JSON and log the structure
    final calendarJsonList =
        calendars.map((c) => c.toJson(email: email)).toList();

    // Log each Google calendar being sent (NESTED structure)
    for (int i = 0; i < calendarJsonList.length; i++) {
      final cal = calendarJsonList[i];
      print('📋 [GOOGLE] Calendar $i: "${cal['summary']}"');
      print('  🆔 ID: ${cal['id']}');
      print('  🔗 Provider ID: ${cal['providerCalendarId']}');
      print('  📊 Source: ${cal['source']}');
      print('  👤 User: ${cal['user']}');
      print('  📧 Email: ${cal['email']}');
      print('  🔄 Structure: NESTED (preferences object preserved)');

      // Log nested preferences structure
      final preferences = cal['preferences'];
      if (preferences != null) {
        print('  📁 Preferences (nested):');
        print('    📂 ImportSettings:');
        final importSettings = preferences['importSettings'];
        if (importSettings != null) {
          print('      ✅ importAll: ${importSettings['importAll']}');
          print('      📝 importSubject: ${importSettings['importSubject']}');
          print('      📄 importBody: ${importSettings['importBody']}');
          print(
              '      📞 importConferenceInfo: ${importSettings['importConferenceInfo']}');
          print(
              '      👥 importOrganizer: ${importSettings['importOrganizer']}');
          print(
              '      📮 importRecipients: ${importSettings['importRecipients']}');
        }
        print('    🏷️ category: "${preferences['category']}"');
        print('    🎨 color: "${preferences['color']}"');
      }

      // Log metadata
      final metadata = cal['metadata'];
      if (metadata != null) {
        print('  📋 Metadata:');
        print('    📛 title: "${metadata['title']}"');
        print('    📝 description: "${metadata['description']}"');
        print('    🌍 timeZone: "${metadata['timeZone']}"');
      }
      print('  ─────────────────────────────────');
    }

    final requestBody = {
      'user': userId,
      'email': email,
      'calendars': calendarJsonList,
      'batchSize': calendars.length,
    };

    print(
        '📤 [GoogleCalendarService] Sending NESTED structure to: ${Config.backendSaveSelectedGoogleCalendars}');

    try {
      final response = await _apiClient.post(
        Config.backendSaveSelectedGoogleCalendars,
        body: requestBody,
        token: await _authService.getAuthToken(),
      );

      _handleBatchResponse(response);
    } catch (e) {
      throw _handleError('saving calendars', e);
    }
  }

  // Helper methods
  // Future<String> _getValidToken() async {
  //   if (_cachedToken == null) {
  //     _cachedToken = await _authService.getAuthToken();
  //   }
  //   return _cachedToken!;
  // }

  void _handleBatchResponse(http.Response response) {
    print(
        'Entered handleBatchResponse, received response with status code: ${response.statusCode}');
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

  Future<CalendarPage> fetchCalendarsPage({
    required String userId,
    required String email,
    String? pageToken,
  }) async {
    print('Entering fetchCalendarsPage');
    try {
      final response = await _apiClient
          .post(
            '$_baseUrl/calendars/list',
            body: {
              'userId': userId,
              'email': email,
              'pageToken': pageToken,
            },
            token: await _authService.getAuthToken(),
          )
          .timeout(
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
