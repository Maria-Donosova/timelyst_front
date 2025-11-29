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
  
  // Caching
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 1);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  TaskProvider({AuthService? authService}) : _authService = authService;

  void setAuth(AuthService authService) {
    _authService = authService;
  }

  

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    print("Entered fetchTasks in TaskProvider");
    
    // Check cache
    if (!forceRefresh && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration && 
        _tasks.isNotEmpty) {
      print("⚡ [TaskProvider] Returning cached tasks");
      return;
    }

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
        Duration(seconds: 45), // Allow more time for backend processing
        onTimeout: () {
          print('⏰ [TaskProvider] Task fetching timed out after 45 seconds');
          throw TimeoutException('Task fetching timed out', Duration(seconds: 45));
        }
      );
      _lastFetchTime = DateTime.now();
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

    // Optimistic update
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = Task(
      taskId: tempId,
      title: title,
      category: category,
      status: 'pending',
    );
    
    _tasks.add(newTask);
    notifyListeners();

    try {
      final createdTask = await TasksService.createTask(authToken, newTask);
      
      // Replace temp task with real one
      final index = _tasks.indexWhere((t) => t.taskId == tempId);
      if (index != -1) {
        _tasks[index] = createdTask;
        notifyListeners();
      }
    } catch (e) {
      // Revert on failure
      _tasks.removeWhere((t) => t.taskId == tempId);
      _errorMessage = 'Failed to create task: $e';
      notifyListeners();
    }
  }

  Future<void> markTaskAsComplete(String taskId) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    // Find task to revert if needed
    final taskIndex = _tasks.indexWhere((t) => t.taskId == taskId);
    if (taskIndex == -1) return;
    final task = _tasks[taskIndex];

    // Optimistic update
    _tasks.removeAt(taskIndex);
    notifyListeners();

    try {
      // Use the dedicated markTaskAsDone method from TasksService
      await TasksService.markTaskAsDone(taskId, authToken);
    } catch (e) {
      // Revert on failure
      _tasks.insert(taskIndex, task);
      _errorMessage = 'Failed to mark task as complete: $e';
      notifyListeners();
    }
  }

  // Update to allow for updates of title and category
  Future<void> updateTask(String taskId, String title, String category) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    final index = _tasks.indexWhere((task) => task.taskId == taskId);
    if (index == -1) return;
    
    final originalTask = _tasks[index];

    // Create an updated task with the new values
    final updatedTask = Task(
      taskId: taskId,
      title: title,
      status: originalTask.status,
      category: category,
      task_type: originalTask.task_type,
    );

    // Optimistic update
    _tasks[index] = updatedTask;
    notifyListeners();

    try {
      // Send the update to the server
      await TasksService.updateTask(taskId, authToken, updatedTask);
    } catch (e) {
      // Revert on failure
      _tasks[index] = originalTask;
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_authService == null) return;
    final authToken = await _authService!.getAuthToken();
    if (authToken == null) return;

    final index = _tasks.indexWhere((task) => task.taskId == taskId);
    if (index == -1) return;
    final originalTask = _tasks[index];

    // Optimistic update
    _tasks.removeAt(index);
    notifyListeners();

    try {
      await TasksService.deleteTask(taskId, authToken);
    } catch (e) {
      // Revert on failure
      _tasks.insert(index, originalTask);
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