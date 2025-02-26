import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/task.dart';

class TasksService {
  static Future<List<Task>> fetchUserTasks(
      String userId, String authToken) async {
    print("Entering fetchUserTasks in TasksService");

    // Define the GraphQL query string
    final String query = '''
        query UserTasks(\$userId: String!) {
          user(id: \$userId) {
            tasks {
              id
              title
              task_type
              category
              dateCreated
              dateChanged
              creator
            }
          }
        }
    ''';

    final String encodedQuery = Uri.encodeComponent(query);
    // Send the HTTP POST request
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/graphql?query=$encodedQuery&variables={"userId":"$userId"}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    // Check the status code
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Fetching tasks failed with errors: $errors');
        throw Exception(
            'Fetching tasks failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Extract the tasks from the response
      final List<dynamic> tasksData = data['data']['user']['tasks'];

      // Parse the tasks into a List<Task>
      final List<Task> tasks =
          tasksData.map((task) => Task.fromJson(task)).toList();

      if (tasks.isEmpty) {
        print('No tasks found for user');
      }
      return tasks;
    } else {
      // Handle non-200 status codes
      print('Failed to fetch tasks: ${response.statusCode}');
      throw Exception('Failed to fetch tasks: ${response.statusCode}');
    }
  }

  static Future<void> updateTask(
      String taskId, String authToken, Task updatedTask) async {
    print("Entering updateTask in TasksService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateTask(\$taskId: String!, \$input: TaskInput!) {
          updateTask(id: \$taskId, input: \$input) {
            id
            title
            task_type
            category
            dateCreated
            dateChanged
            creator
          }
        }
    ''';

    final Map<String, dynamic> variables = {
      'taskId': taskId,
      'input': updatedTask.toJson(),
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Updating task failed with errors: $errors');
        throw Exception(
            'Updating task failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      print('Task updated successfully');
    } else {
      print('Failed to update task: ${response.statusCode}');
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  static Future<void> deleteTask(String taskId, String authToken) async {
    print("Entering deleteTask in TasksService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation DeleteTask(\$taskId: String!) {
          deleteTask(id: \$taskId)
        }
    ''';

    final response = await http.post(
      Uri.parse('http://localhost:3000/graphql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': {'taskId': taskId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Deleting task failed with errors: $errors');
        throw Exception(
            'Deleting task failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      print('Task deleted successfully');
    } else {
      print('Failed to delete task: ${response.statusCode}');
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }
}
