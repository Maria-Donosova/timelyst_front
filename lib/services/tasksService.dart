import 'dart:convert';
import '../config/envVarConfig.dart';
import '../models/task.dart';
import '../utils/apiClient.dart';

class TasksService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<Task>> fetchUserTasks(String authToken, {bool? completed}) async {
    try {
      String url = '${Config.backendURL}/tasks';
      if (completed != null) {
        url += '?completed=$completed';
      }

      final response = await _apiClient.get(
        url,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((task) => Task.fromJson(task)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Task> createTask(String authToken, Map<String, dynamic> taskInput) async {
    try {
      final response = await _apiClient.post(
        '${Config.backendURL}/tasks',
        body: taskInput,
        token: authToken,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to create task: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Task> updateTask(String id, String authToken, Map<String, dynamic> taskInput) async {
    try {
      final response = await _apiClient.put(
        '${Config.backendURL}/tasks/$id',
        body: taskInput,
        token: authToken,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to update task: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteTask(String id, String authToken) async {
    try {
      final response = await _apiClient.delete(
        '${Config.backendURL}/tasks/$id',
        token: authToken,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}