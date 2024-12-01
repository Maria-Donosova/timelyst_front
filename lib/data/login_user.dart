import 'package:http/http.dart' as http;
import 'dart:convert';

import '../service/auth_service.dart';

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

    // Parse the JSON response
    final data = jsonDecode(response.body);
    print('Data received: $data');

    // Check for errors in the response
    if (data['errors'] != null) {
      final errorMessage = data['errors'][0]['message'];
      throw Exception('Error during login: $errorMessage');
    }

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = jsonDecode(response.body);
      print('Data received: $data');

      // Extract token, userId, and role from the response
      final token = data['data']['userLogin']['token'];

      // Use AuthService to store the token securely
      final authService = AuthService();
      await authService.saveAuthToken(token);

      print('Token stored in jwt storage: $token');
    }
  } catch (e) {
    print('PrintError for E: $e');
    throw Exception('$e');
  }
}
