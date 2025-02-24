import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:timelyst_flutter/models/timeEvent.dart'; // Assuming you have a TimeEvent model
// import 'package:timelyst_flutter/models/dayEvent.dart'; // Assuming you have a DayEvent model

class EventService {
  static const String _baseUrl = 'http://localhost:3000/graphql';

  static Future<List<TimeEvent>> fetchTimeEvents(
      String userId, String authToken) async {
    final String query = '''
      query TimeEvents(\$userId: String!) {
        timeEvents(userId: \$userId) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          is_allDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'userId': userId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to fetch time events: ${data['errors']}');
      }
      final List<dynamic> timeEventsJson = data['data']['timeEvents'];
      return timeEventsJson.map((json) => TimeEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch time events: ${response.statusCode}');
    }
  }

  static Future<List<DayEvent>> fetchDayEvents(
      String userId, String authToken) async {
    final String query = '''
      query DayEvents(\$userId: String!) {
        dayEvents(userId: \$userId) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          recurrenceId
          recurrenceRule
          exceptionDates
          day_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'userId': userId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to fetch day events: ${data['errors']}');
      }
      final List<dynamic> dayEventsJson = data['data']['dayEvents'];
      return dayEventsJson.map((json) => DayEvent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch day events: ${response.statusCode}');
    }
  }

  static Future<TimeEvent> createTimeEvent(
      Map<String, dynamic> timeEventInput, String authToken) async {
    final String mutation = '''
      mutation CreateTimeEvent(\$timeEventInput: TimeEventInput!) {
        createTimeEvent(timeEventInput: \$timeEventInput) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          is_allDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'timeEventInput': timeEventInput},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to create time event: ${data['errors']}');
      }
      return TimeEvent.fromJson(data['data']['createTimeEvent']);
    } else {
      throw Exception('Failed to create time event: ${response.statusCode}');
    }
  }

  static Future<DayEvent> createDayEvent(
      Map<String, dynamic> dayEventInput, String authToken) async {
    final String mutation = '''
      mutation CreateDayEvent(\$dayEventInput: DayEventInput!) {
        createDayEvent(dayEventInput: \$dayEventInput) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          recurrenceId
          recurrenceRule
          exceptionDates
          day_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'dayEventInput': dayEventInput},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to create day event: ${data['errors']}');
      }
      return DayEvent.fromJson(data['data']['createDayEvent']);
    } else {
      throw Exception('Failed to create day event: ${response.statusCode}');
    }
  }

  static Future<TimeEvent> updateTimeEvent(
      String id, Map<String, dynamic> timeEventInput, String authToken) async {
    final String mutation = '''
      mutation UpdateTimeEvent(\$id: ID!, \$timeEventInput: TimeEventInput!) {
        updateTimeEvent(id: \$id, timeEventInput: \$timeEventInput) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          is_allDay
          recurrenceId
          recurrenceRule
          exceptionDates
          time_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'id': id, 'timeEventInput': timeEventInput},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to update time event: ${data['errors']}');
      }
      return TimeEvent.fromJson(data['data']['updateTimeEvent']);
    } else {
      throw Exception('Failed to update time event: ${response.statusCode}');
    }
  }

  static Future<DayEvent> updateDayEvent(
      String id, Map<String, dynamic> dayEventInput, String authToken) async {
    final String mutation = '''
      mutation UpdateDayEvent(\$id: ID!, \$dayEventInput: DayEventInput!) {
        updateDayEvent(id: \$id, dayEventInput: \$dayEventInput) {
          id
          event_title
          category
          event_startDate
          event_endDate
          start_timeZone
          end_timeZone
          user_calendars
          source_calendar
          event_organizer
          recurrenceId
          recurrenceRule
          exceptionDates
          day_eventInstance
          event_attendees
          event_body
          event_location
          event_conferenceDetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'id': id, 'dayEventInput': dayEventInput},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to update day event: ${data['errors']}');
      }
      return DayEvent.fromJson(data['data']['updateDayEvent']);
    } else {
      throw Exception('Failed to update day event: ${response.statusCode}');
    }
  }

  static Future<bool> deleteTimeEvent(String id, String authToken) async {
    final String mutation = '''
      mutation DeleteTimeEvent(\$id: ID!) {
        deleteTimeEvent(id: \$id)
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'id': id},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to delete time event: ${data['errors']}');
      }
      return data['data']['deleteTimeEvent'];
    } else {
      throw Exception('Failed to delete time event: ${response.statusCode}');
    }
  }

  static Future<bool> deleteDayEvent(String id, String authToken) async {
    final String mutation = '''
      mutation DeleteDayEvent(\$id: ID!) {
        deleteDayEvent(id: \$id)
      }
    ''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'id': id},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        throw Exception('Failed to delete day event: ${data['errors']}');
      }
      return data['data']['deleteDayEvent'];
    } else {
      throw Exception('Failed to delete day event: ${response.statusCode}');
    }
  }
}
