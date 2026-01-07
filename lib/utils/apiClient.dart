import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timelyst_flutter/utils/auth_event_bus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void _checkResponse(http.Response response) {
    if (response.statusCode == 401) {
      AuthEventBus.emit(AuthEvent.unauthorized);
    }
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      'X-Timezone': timeZoneName,
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await _client.post(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );

    _checkResponse(response);
    return response;
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      'X-Timezone': timeZoneName,
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await _client.delete(
      Uri.parse(url),
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );

    _checkResponse(response);
    return response;
  }

  Future<http.Response> get(String url,
      {Map<String, String>? headers, String? token}) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'X-Timezone': timeZoneName,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await _client.get(
      Uri.parse(url),
      headers: defaultHeaders,
    );

    _checkResponse(response);
    return response;
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'X-Timezone': timeZoneName,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final response = await _client.put(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );

    _checkResponse(response);
    return response;
  }
}
