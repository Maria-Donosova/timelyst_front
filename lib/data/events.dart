import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/env_variables_config.dart';
import '../../models/customApp.dart';
import '../../models/dayEvent.dart';
import '../../models/timeEvent.dart';
import '../utils/eventsMapper.dart';

class EventService {
  // Fetch DayEvents and map them to CustomAppointment
  static Future<List<CustomAppointment>> fetchDayEvents(
      String userId, String authToken) async {
    final String query = '''
      query DayEvents(\$userId: String!) {
        dayEvents(userId: \$userId) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          day_eventInstance
          category
          event_body
          event_location
          event_conferencedetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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
      final List<DayEvent> dayEvents =
          dayEventsJson.map((json) => DayEvent.fromJson(json)).toList();
      return dayEvents
          .map((event) => EventMapper.mapDayEventToCustomAppointment(event))
          .toList();
    } else {
      throw Exception('Failed to fetch day events: ${response.statusCode}');
    }
  }

  // Fetch TimeEvents and map them to CustomAppointment
  static Future<List<CustomAppointment>> fetchTimeEvents(
      String userId, String authToken) async {
    final String query = '''
      query TimeEvents(\$userId: String!) {
        timeEvents(userId: \$userId) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          time_eventInstance
          category
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
      Uri.parse(Config.backendGraphqlURL),
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
      final List<TimeEvent> timeEvents =
          timeEventsJson.map((json) => TimeEvent.fromJson(json)).toList();
      return timeEvents
          .map((event) => EventMapper.mapTimeEventToCustomAppointment(event))
          .toList();
    } else {
      throw Exception('Failed to fetch time events: ${response.statusCode}');
    }
  }

  // Create a TimeEvent and map it to CustomAppointment
  static Future<CustomAppointment> createTimeEvent(
      Map<String, dynamic> timeEventInput, String authToken) async {
    final String mutation = '''
      mutation CreateTimeEvent(\$timeEventInput: TimeEventInput!) {
        createTimeEvent(timeEventInput: \$timeEventInput) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          time_eventInstance
          category
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
      Uri.parse(Config.backendGraphqlURL),
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
      final TimeEvent timeEvent =
          TimeEvent.fromJson(data['data']['createTimeEvent']);
      return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
    } else {
      throw Exception('Failed to create time event: ${response.statusCode}');
    }
  }

  // Create a DayEvent and map it to CustomAppointment
  static Future<CustomAppointment> createDayEvent(
      Map<String, dynamic> dayEventInput, String authToken) async {
    final String mutation = '''
      mutation CreateDayEvent(\$dayEventInput: DayEventInput!) {
        createDayEvent(dayEventInput: \$dayEventInput) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          day_eventInstance
          category
          event_body
          event_location
          event_conferencedetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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
      final DayEvent dayEvent =
          DayEvent.fromJson(data['data']['createDayEvent']);
      return EventMapper.mapDayEventToCustomAppointment(dayEvent);
    } else {
      throw Exception('Failed to create day event: ${response.statusCode}');
    }
  }

  // Update a TimeEvent and map it to CustomAppointment
  static Future<CustomAppointment> updateTimeEvent(
      String id, Map<String, dynamic> timeEventInput, String authToken) async {
    final String mutation = '''
      mutation UpdateTimeEvent(\$id: ID!, \$timeEventInput: TimeEventInput!) {
        updateTimeEvent(id: \$id, timeEventInput: \$timeEventInput) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          time_eventInstance
          category
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
      Uri.parse(Config.backendGraphqlURL),
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
      final TimeEvent timeEvent =
          TimeEvent.fromJson(data['data']['updateTimeEvent']);
      return EventMapper.mapTimeEventToCustomAppointment(timeEvent);
    } else {
      throw Exception('Failed to update time event: ${response.statusCode}');
    }
  }

  // Update a DayEvent and map it to CustomAppointment
  static Future<CustomAppointment> updateDayEvent(
      String id, Map<String, dynamic> dayEventInput, String authToken) async {
    final String mutation = '''
      mutation UpdateDayEvent(\$id: ID!, \$dayEventInput: DayEventInput!) {
        updateDayEvent(id: \$id, dayEventInput: \$dayEventInput) {
          _id
          userId
          createdBy
          user_calendars
          calendarId
          googleEventId
          googleKind
          googleEtag
          creator
          organizer
          event_title
          start
          end
          is_allDay
          recurrence
          recurrenceId
          exceptionDates
          day_eventInstance
          category
          event_body
          event_location
          event_conferencedetails
          reminder
          holiday
          createdAt
          updatedAt
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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
      final DayEvent dayEvent =
          DayEvent.fromJson(data['data']['updateDayEvent']);
      return EventMapper.mapDayEventToCustomAppointment(dayEvent);
    } else {
      throw Exception('Failed to update day event: ${response.statusCode}');
    }
  }

  // Delete a TimeEvent
  static Future<bool> deleteTimeEvent(String id, String authToken) async {
    final String mutation = '''
      mutation DeleteTimeEvent(\$id: ID!) {
        deleteTimeEvent(id: \$id)
      }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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

  // Delete a DayEvent
  static Future<bool> deleteDayEvent(String id, String authToken) async {
    final String mutation = '''
      mutation DeleteDayEvent(\$id: ID!) {
        deleteDayEvent(id: \$id)
      }
    ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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
