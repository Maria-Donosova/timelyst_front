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

  // You can add other methods like get, put, delete here
}
