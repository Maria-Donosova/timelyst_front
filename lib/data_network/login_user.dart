import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

Future<void> loginUser(String email, String password) async {
  try {
    print("Entering loginUser in flutter");
    print('Logging in with email: $email and password: $password');
    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': '''
        mutation {
          userLogin(email: "$email", password: "$password") {
            token
            userId
            role
          }
        }
      ''',
      }),
    );
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['userLogin']['token'];
      final userId = data['data']['userLogin']['userId'];
      final role = data['data']['userLogin']['role'];

      // Store the token securely
      await storage.write(key: 'jwt', value: token);

      // Optionally, store userId and role if needed
      await storage.write(key: 'userId', value: userId);
      await storage.write(key: 'role', value: role);
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during login: $e');
    throw Exception('Failed to login: $e');
  }
}
