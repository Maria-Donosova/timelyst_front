import 'package:flutter/material.dart';
import 'package:timelyst_flutter/data/tasks.dart';
import 'package:timelyst_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTasks(String userId, String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await TasksService.fetchUserTasks(userId, authToken);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markTaskAsComplete(String taskId, String authToken) async {
    try {
      final task = _tasks.firstWhere((task) => task.id == taskId);
      final updatedTask = task..status = 'completed';

      await TasksService.updateTask(taskId, authToken, updatedTask);

      // Update the local task list
      final index = _tasks.indexWhere((task) => task.id == taskId);
      _tasks[index] = updatedTask;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark task as complete: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId, String authToken) async {
    try {
      await TasksService.deleteTask(taskId, authToken);

      // Remove the task from the local list
      _tasks.removeWhere((task) => task.id == taskId);
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
