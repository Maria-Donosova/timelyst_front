import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/authService.dart';

Future<void> loginUser(String email, String password) async {
  try {
    print("Entering loginUser in flutter");
    print('Logging in with email: $email and password: $password');

    // Define the GraphQL mutation query string
    final String query = '''
      mutation UserLogin(\$email: String!, \$password: String!) {
        userLogin(email: \$email, password: \$password) {
          token
          userId
          role
        }
      }
    ''';

    // Define the variables
    final Map<String, dynamic> variables = {
      'email': email,
      'password': password,
    };

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    // Check the status code
    if (response.statusCode == 200) {
      //if the server returns a 200 OK response, the user was successfully registered, parse json
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Login failed with errors: $errors');
        throw Exception(
            'Login failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      // Check for data errors
      if (data['data']['userLogin']['errors'] != null &&
          data['data']['userLogin']['errors'].length > 0) {
        // Handle errors
        final errors = data['data']['userLogin']['errors'];
        print('Login failed with errors: $errors');
        throw Exception(
            'Login failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract token, userId, and role from the response
      final token = data['data']['userLogin']['token'];
      final userId = data['data']['userLogin']['userId'];
      final role = data['data']['userLogin']['role'];
      print('User created with token: $token, userId: $userId, role: $role');

      // Use AuthService to store the token securely
      final authService = AuthService();
      await authService.saveAuthToken(token);

      print('Token stored in jwt storage for logged in user: $token');
    }
  } catch (e) {
    print('PrintError for E: $e');
    throw Exception('$e');
  }
}
