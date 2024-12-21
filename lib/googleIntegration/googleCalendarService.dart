import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/calendar.dart';

class GoogleCalendarService {
  // Fetch Google calendars from the backend
  Future<List<Calendar>> fetchGoogleCalendars(
      String userId, String email) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://your-backend-url.com/fetch-calendars?userId=$userId&email=$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_JWT_TOKEN', // Include your JWT token for authentication
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((calendar) => Calendar.fromJson(calendar)).toList();
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
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-url.com/save-calendars'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_JWT_TOKEN', // Include your JWT token for authentication
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
