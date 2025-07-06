// Formerly lib/data/tasks.dart
// Service for task-related data operations

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/envVarConfig.dart';
import '../models/task.dart';

class TasksService {
  static Future<List<Task>> fetchUserTasks(String authToken) async {
    final String query = '''
        query UserTasks {
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
    ''';
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'query': query}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        throw Exception(
            'Fetching tasks failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      final List<dynamic> tasksData = data['data']['tasks'];
      final List<Task> tasks =
          tasksData.map((task) => Task.fromJson(task)).toList();
      final List<Task> activeTasks =
          tasks.where((task) => task.status != 'done').toList();
      return activeTasks;
    } else {
      throw Exception('Failed to fetch tasks: ${response.statusCode}');
    }
  }

  static Future<Task> fetchTaskById(
      String taskId, String authToken, String userId) async {
    const String query = '''
    query FetchTask(\$taskId: String!, \$userId: String!) {
      task(id: \$taskId, user_id: \$userId) {
        taskId
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
        'variables': {'taskId': taskId, 'userId': userId}
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
    final String mutation = '''
    mutation CreateTask(\$taskInput: TaskInputData!) {
      createTask(taskInput: \$taskInput) {
        title
        status
        task_type
        category
      }
    }
  ''';
    final Map<String, dynamic> variables = {
      'taskInput': {
        'title': newTask.title,
        'status': newTask.status,
        'task_type': newTask.task_type,
        'category': newTask.category,
      },
    };
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        throw Exception(
            'Creating task failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      final taskData = data['data']['createTask'];
      if (taskData['id'] == null) {
        taskData['id'] = '';
      }
      final createdTask = Task.fromJson(taskData);
      return createdTask;
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  static Future<void> markTaskAsDone(String taskId, String authToken) async {
    final String mutation = '''
    mutation MarkTaskAsDone(\$taskId: String!) {
      markTaskAsDone(taskId: \$taskId) {
        status
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
        'query': mutation,
        'variables': {'taskId': taskId}
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        throw Exception(
            'Marking task as done failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      // No return needed for void
    } else {
      throw Exception('Failed to mark task as done: ${response.statusCode}');
    }
  }

  static Future<void> updateTask(
      String taskId, String authToken, Task updatedTask) async {
    final String mutation = '''
    mutation UpdateTask(
      \$taskId: String!,
      \$taskInput: TaskInputData!
    ) {
      updateTask(
        taskId: \$taskId,
        taskInput: \$taskInput
      ) {
        id
        title
        status
        task_type
        category
        updatedAt
      }
    }
  ''';

    final Map<String, dynamic> variables = {
      'taskId': taskId,
      'taskInput': {
        'title': updatedTask.title,
        'status': updatedTask.status,
        'task_type': updatedTask.task_type,
        'category': updatedTask.category,
      },
    };

    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        throw Exception(
            'Updating task failed: ${errors.map((e) => e['message']).join(", ")}\[0m');
      }
      // No return needed for void
    } else {
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  static Future<void> deleteTask(String taskId, String authToken) async {
    final String mutation = '''
    mutation DeleteTask(\$taskId: String!) {
      deleteTask(taskId: \$taskId) {
        id
      }
    }
  ''';
    final Map<String, dynamic> variables = {'taskId': taskId};
    final response = await http.post(
      Uri.parse(Config.backendGraphqlURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'query': mutation, 'variables': variables}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].length > 0) {
        final errors = data['errors'];
        throw Exception(
            'Deleting task failed: ${errors.map((e) => e['message']).join(", ")}');
      }
      // No return needed for void
    } else {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }
}
