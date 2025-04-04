import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env_variables_config.dart';

import '../../models/task.dart';

class TasksService {
  static Future<List<Task>> fetchUserTasks(
      String userId, String authToken) async {
    print("Entering fetchUserTasks in TasksService");
    print("UserId: $userId");

    // Define the GraphQL query string
    final String query = '''
        query UserTasks(\$userId: String!) {
          user(id: \$userId) {
            tasks {
              id
              title
              status
              task_type
              category
              createdAt
              updatedAt
            }
          }
        }
    ''';

    final String encodedQuery = Uri.encodeComponent(query);
    // Send the HTTP POST request
    final response = await http.get(
      Uri.parse(
          '${Config.backendGraphqlURL}?query=$encodedQuery&variables={"userId":"$userId"}'),
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

  // Helper function to fetch a single task by ID (if needed)
  static Future<Task> fetchTaskById(String taskId, String authToken) async {
    // Define the GraphQL query to fetch a single task
    const String query = '''
    query FetchTask(\$taskId: String!) {
      task(id: \$taskId) {
        id
        title
        status
        task_type
        category
        createdAt
        updatedAt
      }
    }
  ''';

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': query,
        'variables': {'taskId': taskId},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        throw Exception(
            'GraphQL errors: ${data['errors'].map((e) => e['message']).join(", ")}');
      }
      return Task.fromJson(data['data']['task']);
    } else {
      throw Exception('Failed to fetch task: ${response.statusCode}');
    }
  }

  static Future<Task> createTask(String authToken, Task newTask) async {
    print("Entering createTask in TasksService");

    // Define the GraphQL mutation string
    final String mutation = '''
    mutation CreateTask(\$taskInput: TaskInputData!) {
      createTask(taskInput: \$taskInput) {
        id
        title
        status
        task_type
        category
        createdAt
        updatedAt
      }
    }
  ''';

    // Prepare the variables for the mutation
    final Map<String, dynamic> variables = {
      'taskInput': newTask.toJson(), // Convert the task to JSON
    };

    // Send the HTTP POST request
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'query': mutation,
        'variables': variables,
      }),
    );

    // Check the status code
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Check for GraphQL errors
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        print('Creating task failed with errors: $errors');
        throw Exception(
            'Creating task failed: ${errors.map((e) => e['message']).join(", ")}');
      }

      // Parse and return the created task
      final createdTask = Task.fromJson(data['data']['createTask']);
      print('Task created successfully: ${createdTask.id}');
      return createdTask;
    } else {
      print('Failed to create task: ${response.statusCode}');
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  static Future<void> updateTask(
      String taskId, String authToken, Task updatedTask) async {
    print("Entering updateTask in TasksService");

    // Define the GraphQL mutation string
    final String mutation = '''
        mutation UpdateTask(\$taskId: String!, \$input: TaskInputData!) {
          updateTask(id: \$taskId, input: \$input) {
            id
            title
            status
            task_type
            category
            createdAt
            updatedAt
          }
        }
    ''';

    final Map<String, dynamic> variables = {
      'taskId': taskId,
      'input': updatedTask.toJson(),
    };

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
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

  static Future<void> markTaskAsComplete(
      String taskId, String authToken) async {
    try {
      // Fetch the task to be updated (if needed)
      // Note: If you already have the task locally, you can skip this step.
      final task = await fetchTaskById(taskId, authToken);

      // Update the task status
      final updatedTask = task..status = 'completed';

      // Call the updateTask function
      await updateTask(taskId, authToken, updatedTask);

      print('Task marked as complete successfully');
    } catch (e) {
      print('Failed to mark task as complete: $e');
      throw Exception('Failed to mark task as complete: $e');
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
      Uri.parse(Config.backendGraphqlURL),
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
