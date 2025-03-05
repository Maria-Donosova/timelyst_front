import 'package:http/http.dart' as http;
import 'package:timelyst_flutter/config/env_variables_config.dart';
import 'dart:convert';

import '../services/authService.dart';

Future<Map<String, dynamic>> registerUser(String email, String password,
    String name, String lastName, bool consent) async {
  print("Entering registerUser in flutter");
  print(
      'Regestring with email: $email, password: $password, name: $name, lastName: $lastName, consent: $consent');
  try {
// Define the GraphQL mutation query string
    final String query = '''
    mutation RegisterUser(\$email: String!, \$name: String!, \$lastName: String!, \$password: String!, \$consent: Boolean!) {
      registerUser(userInput: {email: \$email, name: \$name, last_name: \$lastName, password: \$password, consent: \$consent}) {
          token
          userId
          role
      }
    }
  ''';

    // Define the variables
    final Map<String, dynamic> variables = {
      'email': email,
      'name': name,
      'lastName': lastName,
      'password': password,
      'consent': consent,
    };

    // Send the HTTP POST request
    final response = await http.post(
      //Uri.parse(Config.backendURL),
      Uri.parse(Config.backendGraphqlURL),
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
        print('Registration failed with errors: $errors');
        throw Exception(
            'Registration failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Check for data errors
      if (data['data']['registerUser']['errors'] != null &&
          data['data']['registerUser']['errors'].length > 0) {
        // Handle errors
        final errors = data['data']['registerUser']['errors'];
        print('Registration failed with errors: $errors');
        throw Exception(
            'Registration failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract token, userId, and role from the response
      final token = data['data']['registerUser']['token'];
      final userId = data['data']['registerUser']['userId'];
      final role = data['data']['registerUser']['role'];
      print('User created with token: $token, userId: $userId, role: $role');

      // Use AuthService to store the token securely
      final authService = AuthService();
      await authService.saveAuthToken(token);
      await authService.saveUserId(userId);

      print('Token stored in jwt storage for registered user: $token');
      print('UserId stored in secure storage: $userId');

      // Return the token and userId
      return {
        'token': token,
        'userId': userId,
        'role': role,
      };
    } else {
      // If the server returns an error response, throw an exception
      throw Exception('Failed to signup: ${response.statusCode}');
    }
  } catch (e) {
    print('Error registering user: $e');
    rethrow;
  }
}
