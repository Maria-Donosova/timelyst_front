import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/tasksService.dart';
import 'package:timelyst_flutter/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTasks(String authToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await TasksService.fetchUserTasks(authToken);
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
  Future<void> updateTask(
      String taskId, String authToken, String title, String category) async {
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

  Future<void> deleteTask(String taskId, String authToken) async {
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
