import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

Future<void> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/graphql'),
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

Future<String?> getToken() async {
  return await storage.read(key: 'jwt');
}

Future<void> saveRefreshToken(String refreshToken) async {
  await storage.write(key: 'refreshToken', value: refreshToken);
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refreshToken');
}
