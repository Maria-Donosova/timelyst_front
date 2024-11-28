import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> registerUser(String email, String password, String name,
    String lastName, bool consent) async {
  print("Entering registerUser in flutter");
  print(
      'Regestring with email: $email, password: $password, name: $name, lastName: $lastName, consent: $consent');

  // Define the GraphQL mutation query string
  final String query = '''
    mutation RegisterUser(\$email: String!, \$name: String!, \$lastName: String!, \$password: String!, \$consent: Boolean!) {
      registerUser(userInput: {email: \$email, name: \$name, last_name: \$lastName, password: \$password, consent: \$consent}) {
        id
        name
        last_name
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
    Uri.parse('http://localhost:3000/graphql'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'query': query,
      'variables': variables,
    }),
  );

  print("Response: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final id = data['data']['registerUser']['id'];
    final name = data['data']['registerUser']['name'];
    final lastName = data['data']['registerUser']['last_name'];
    print('User created with id: $id, name: $name, last name: $lastName');
  } else {
    throw Exception('Failed to signup: ${response.statusCode}');
  }
}
