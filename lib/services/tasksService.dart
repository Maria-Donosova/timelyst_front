// Formerly lib/data/tasks.dart
// Service for task-related data operations

import 'dart:convert';
import '../config/envVarConfig.dart';
import '../models/task.dart';
import '../utils/apiClient.dart';

class TasksService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<Task>> fetchUserTasks(String authToken, {bool includeDone = false}) async {
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
    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {'query': query},
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
      
      if (includeDone) {
        return tasks;
      }

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
    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {
        'query': query,
        'variables': {'taskId': taskId, 'userId': userId}
      },
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
    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {'query': mutation, 'variables': variables},
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

  static Future<void> markTaskAsDone(String id, String authToken) async {
    final String mutation = '''
    mutation MarkTaskAsDone(\$id: String!) {
      markTaskAsDone(id: \$id) {
        status
      }
    }
  ''';
    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {
        'query': mutation,
        'variables': {'id': id}
      },
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
      String id, String authToken, Task updatedTask) async {
    final String mutation = '''
    mutation UpdateTask(
      \$id: String!,
      \$taskInput: TaskInputData!
    ) {
      updateTask(
        id: \$id,
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
      'id': id,
      'taskInput': {
        'title': updatedTask.title,
        'status': updatedTask.status,
        'task_type': updatedTask.task_type,
        'category': updatedTask.category,
      },
    };

    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {'query': mutation, 'variables': variables},
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

  static Future<void> deleteTask(String id, String authToken) async {
    final String mutation = '''
    mutation DeleteTask(\$id: String!) {
      deleteTask(id: \$id) 
    }
  ''';
    final Map<String, dynamic> variables = {'id': id};
    final response = await _apiClient.post(
      Config.backendGraphqlURL,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
      body: {'query': mutation, 'variables': variables},
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