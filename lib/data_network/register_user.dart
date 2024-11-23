import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> registerUser(String email, String password, String name,
    String lastName, bool consent) async {
  print("Entering registerUser in flutter");
  print(
      'Regestring with email: $email, password: $password, name: $name, lastName: $lastName, consent: $consent');
  final response = await http.post(
    Uri.parse('http://localhost:3000/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'query': '''
        mutation createUser(\$name: String!, \$last_name: String!,\$email: String!, \$password: String!, \$consent: Boolean!) {
        createUser(name: \$name, last_name: \$last_name, email: \$email, password: \$password, consent: \$consent) {
          id
          name
          last_name
        }
      }
      ''',
      'variables': {
        'email': email,
        'password': password,
        'name': name,
        'last_name': lastName,
        'consent': consent,
      },
    }),
  );
  print("Response: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final id = data['data']['createUser']['id'];
    final name = data['data']['createUser']['name'];
    final lastName = data['data']['createUser']['last_name'];
    print('User created with id: $id, name: $name, last name: $lastName');
  } else {
    throw Exception('Failed to signup: ${response.statusCode}');
  }
}
