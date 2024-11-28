import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final storage = FlutterSecureStorage();

Future<void> loginUser(String email, String password) async {
  try {
    print("Entering loginUser in flutter");
    print('Logging in with email: $email and password: $password');
    var url = Uri.parse('http://localhost:3000/graphql');

    // Construct the GraphQL query or mutation
    String query = '''
    mutation {
          userLogin(email: "molly@troy.com", password: "zxcvb") {
            token
            userId
            role
          }
        }
  ''';

    // Create the request body
    Map<String, dynamic> requestBody = {
      'query': query,
    };

    // JSON encode the request body
    String jsonBody = jsonEncode(requestBody);

    // Send the POST request
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonBody,
    );

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      var data = jsonDecode(response.body);
      print('Data received: $data');
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    // print('Response status: ${response.statusCode}');
    // print("Response body: ${response.body}");

    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body);
    //   final token = data['data']['userLogin']['token'];
    //   final userId = data['data']['userLogin']['userId'];
    //   final role = data['data']['userLogin']['role'];

    //   // Store the token securely
    //   await storage.write(key: 'jwt', value: token);

    //   // Optionally, store userId and role if needed
    //   await storage.write(key: 'userId', value: userId);
    //   await storage.write(key: 'role', value: role);
    // } else {
    //   throw Exception('Failed to login: ${response.statusCode}');
    // }
  } catch (e) {
    print('Error during login: $e');
    throw Exception('Failed to login: $e');
  }
}
