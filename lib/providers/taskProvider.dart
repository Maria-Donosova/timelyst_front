import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/tasksService.dart';
import 'package:timelyst_flutter/models/task.dart';
import 'package:timelyst_flutter/services/authService.dart';

class TaskProvider with ChangeNotifier {
  AuthService? _authService;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  TaskProvider({AuthService? authService}) : _authService = authService;

  void setAuth(AuthService authService) {
    _authService = authService;
  }

  

  Future<void> fetchTasks() async {
    print("Entered fetchTasks in TaskProvider");
    if (_authService == null) {
      print("AuthService is null in TaskProvider");
      return;
    }
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) {
      print("AuthToken is null in TaskProvider");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print("🔄 [TaskProvider] Starting API call to fetch tasks...");
      _tasks = await TasksService.fetchUserTasks(authToken).timeout(
        Duration(seconds: 15), // Shorter timeout for tasks - they're typically faster
        onTimeout: () {
          print('⏰ [TaskProvider] Task fetching timed out after 15 seconds');
          throw TimeoutException('Task fetching timed out', Duration(seconds: 15));
        }
      );
      print("✅ [TaskProvider] Fetched ${_tasks.length} tasks successfully");
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch tasks: $e';
      print("❌ [TaskProvider] Error: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(String title, String category) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    try {
      final newTask = Task(
        title: title,
        category: category,
        status: 'pending',
      );
      await TasksService.createTask(authToken, newTask);
      await fetchTasks();
    } catch (e) {
      _errorMessage = 'Failed to create task: $e';
      notifyListeners();
    }
  }

  Future<void> markTaskAsComplete(String taskId) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    try {
      // Use the dedicated markTaskAsDone method from TasksService
      await TasksService.markTaskAsDone(taskId, authToken);

      // Remove the task from the local list since it's now done
      // This matches the behavior in fetchUserTasks which filters out 'done' tasks
      _tasks.removeWhere((task) => task.taskId == taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark task as complete: $e';
      notifyListeners();
    }
  }

  // Update to allow for updates of title and category
  Future<void> updateTask(String taskId, String title, String category) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    try {
      // Find the task to update
      final task = _tasks.firstWhere((task) => task.taskId == taskId);

      // Create an updated task with the new values
      final updatedTask = Task(
        taskId: taskId,
        title: title,
        status: task.status,
        category: category,
        task_type: task.task_type,
      );

      // Send the update to the server
      await TasksService.updateTask(taskId, authToken, updatedTask);

      // Update the local task list
      final index = _tasks.indexWhere((task) => task.taskId == taskId);
      _tasks[index] = updatedTask;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    try {
      await TasksService.deleteTask(taskId, authToken);

      // Remove the task from the local list
      _tasks.removeWhere((task) => task.taskId == taskId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    notifyListeners();
  }
}