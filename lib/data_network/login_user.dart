import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

Future<void> loginUser(String email, String password) async {
  print("Entering loginUser in flutter");
  print('Logging in with email: $email and password: $password');
  final response = await http.post(
    Uri.parse('http://localhost:3000/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'query': '''
        mutation LoginUser(\$email: String!, \$password: String!) {
          userLogin(email: \$email, password: \$password) {
            token
            userId
            role
          }
        }
      ''',
      'variables': {
        'email': email,
        'password': password,
      },
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
}
