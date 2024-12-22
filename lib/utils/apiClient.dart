import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Base URL for the backend API
  final String baseUrl;

  // Constructor to initialize the base URL
  ApiClient({required this.baseUrl});

  // Helper method to build the full URL
  Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }

  // Helper method to set common headers
  Map<String, String> _buildHeaders({String? authToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    // Add the Authorization header if an auth token is provided
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? authToken,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint).replace(queryParameters: queryParams);
      final headers = _buildHeaders(authToken: authToken);

      final response = await http.get(uri, headers: headers);

      // Parse the response
      return _parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    String? authToken,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders(authToken: authToken);
      final jsonBody = body != null ? json.encode(body) : null;

      final response = await http.post(uri, headers: headers, body: jsonBody);

      // Parse the response
      return _parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    String? authToken,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders(authToken: authToken);
      final jsonBody = body != null ? json.encode(body) : null;

      final response = await http.put(uri, headers: headers, body: jsonBody);

      // Parse the response
      return _parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = _buildHeaders(authToken: authToken);

      final response = await http.delete(uri, headers: headers);

      // Parse the response
      return _parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to parse the HTTP response
  Map<String, dynamic> _parseResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      // Successful response
      if (responseBody.isEmpty) {
        return {'success': true, 'data': null};
      }
      return {'success': true, 'data': json.decode(responseBody)};
    } else {
      // Error response
      final errorData = json.decode(responseBody);
      throw HttpException(
        statusCode: statusCode,
        message: errorData['message'] ?? 'Something went wrong',
        data: errorData,
      );
    }
  }
}

// Custom exception for HTTP errors
class HttpException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  HttpException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'HttpException: $statusCode - $message';
  }
}
