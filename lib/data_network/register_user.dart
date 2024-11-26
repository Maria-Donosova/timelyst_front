import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> registerUser(String email, String password, String name,
    String lastName, bool consent) async {
  print("Entering registerUser in flutter");
  print(
      'Regestring with email: $email, password: $password, name: $name, lastName: $lastName, consent: $consent');
  final response = await http.post(
    Uri.parse('http://localhost:3000/graphql'),
    // headers: {
    //   'Content-Type': 'application/json',
    // },
    body: jsonEncode({
      'query': '''
        mutation {
          registerUser(userInput: {email: $email, name: $name, last_name: $lastName, password:$password, consent: $consent}) 
            {
              id
              name
              last_name
            }
          } 
        }
        ''',
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
