// http requests sample
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'storage_service.dart';

// class UserService {
//   final StorageService storageService = StorageService();

//   Future<Map<String, dynamic>> fetchUserData() async {
//     String? token = await storageService.getToken();
//     if (token == null) {
//       throw Exception('Token not available');
//     }

//     final response = await http.get(
//       Uri.parse('https://your-backend-domain.com/api/user'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to fetch user data: ${response.statusCode}');
//     }
//   }
// }


//graphql requests sample
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'storage_service.dart'; 

// class UserService {
//   final StorageService storageService = StorageService();

//   Future<Map<String, dynamic>> fetchUserData() async {
//     String? token = await storageService.getToken();
//     if (token == null) {
//       throw Exception('Token not available');
//     }

//     final HttpLink httpLink = HttpLink('https://your-backend-domain.com/graphql');
//     final AuthLink authLink = AuthLink(
//       getToken: () async => 'Bearer $token',
//     );

//     final Link link = authLink.concat(httpLink);

//     final GraphQLClient client = GraphQLClient(
//       link: link,
//       cache: GraphQLCache(),
//     );

//     final QueryResult result = await client.query(
//       QueryOptions(
//         document: gql('''
//           query GetUserData {
//             user {
//               id
//               name
//               email
//             }
//           }
//         '''),
//       ),
//     );

//     if (result.hasException) {
//       throw Exception('GraphQL error: ${result.exception}');
//     } else {
//       return result.data!['user'];
//     }
//   }
// }