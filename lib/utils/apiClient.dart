import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  Future<http.Response> post(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.post(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.delete(
      Uri.parse(url),
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> get(String url,
      {Map<String, String>? headers, String? token}) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.get(
      Uri.parse(url),
      headers: defaultHeaders,
    );
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers, dynamic body, String? token}) async {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return http.put(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );
  }
}
