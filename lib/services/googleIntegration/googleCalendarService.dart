import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelyst_flutter/config/env_variables_config.dart';
import 'package:timelyst_flutter/services/authService.dart';

import '../../models/calendars.dart';

class GoogleCalendarService {
  // Fetch Google calendars from the backend
  Future<List<Calendar>> fetchGoogleCalendars(
      String userId, String email) async {
    print("Entering fetchGoogleCalendars");
    print("userId: $userId");
    print("email: $email");

    // Retrieve the JWT token from secure storage
    final authService = AuthService();
    final token = await authService.getAuthToken();
    print("Token: $token");

    if (token == null) {
      throw Exception('No JWT token found. Please log in again.');
    }

    try {
      final response = await http.post(
        Uri.parse(Config.backendFetchGoogleCalendars),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'email': email,
        }),
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print("Response body (decoded): $responseBody");

        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];
          print("Data: $data");

          return data.map((calendar) => Calendar.fromJson(calendar)).toList();
        } else {
          throw Exception(
              'Invalid response format: "data" field is missing or not a list');
        }
      } else {
        throw Exception('Failed to load calendars: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching calendars: $e');
      throw Exception('Error fetching calendars: $e');
    }
  }

  // Save selected calendars to the backend
  Future<void> saveSelectedCalendars(
      String userId, List<Calendar> selectedCalendars) async {
    // Retrieve the JWT token from secure storage
    final authService = AuthService();
    final token = await authService.getAuthToken();
    print("Token: $token");

    if (token == null) {
      throw Exception('No JWT token found. Please log in again.');
    }

    try {
      final response = await http.post(
        Uri.parse(Config.backendSaveSelectedGoogleCalendars),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Include your JWT token for authentication
        },
        body: json.encode({
          'userId': userId,
          'selectedCalendars': selectedCalendars
              .map((calendar) => (calendar as Calendar).toJson())
              .toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save calendars: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving calendars: $e');
      throw Exception('Error saving calendars: $e');
    }
  }
}
