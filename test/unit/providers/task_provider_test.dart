import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/services/tasksService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/models/task.dart';
import '../../mocks/mockAuthService.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    });
  });

  group('TaskProvider', () {
    late MockAuthService mockAuthService;
    late TaskProvider taskProvider;

    setUp(() {
      mockAuthService = MockAuthService();
      taskProvider = TaskProvider();
      taskProvider.setAuth(mockAuthService);
    });

    test('initial state is correct', () {
      expect(taskProvider.tasks, isEmpty);
      expect(taskProvider.isLoading, isTrue);
      expect(taskProvider.errorMessage, isEmpty);
    });

    test('fetchTasks updates state on success', () async {
      mockAuthService.setLoginState(true, userId: 'user-1', token: 'token-1');

      final mockTasksJson = [
        {
          'id': 'task-1',
          'userId': 'user-1',
          'title': 'Test Title',
          'description': 'Test Task',
          'priority': 'high',
          'isCompleted': false,
          'createdAt': '2023-01-01T10:00:00.000Z',
          'updatedAt': '2023-01-01T10:00:00.000Z',
        }
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockTasksJson), 200);
      });

      TasksService.apiClient = ApiClient(client: mockClient);

      await taskProvider.fetchTasks();

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].description, 'Test Task');
      expect(taskProvider.isLoading, isFalse);
    });

    test('createTask performs optimistic update and handles success', () async {
      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      
      final createdTaskJson = {
        'id': 'real-id-1',
        'userId': 'u1',
        'title': 'New Task',
        'description': 'New Task',
        'priority': 'low',
        'isCompleted': false,
        'createdAt': '2023-01-01T10:00:00.000Z',
        'updatedAt': '2023-01-01T10:00:00.000Z',
      };

      final mockClient = MockClient((request) async {
        // Add a delay to ensure we can catch the optimistic state
        await Future.delayed(const Duration(milliseconds: 50));
        return http.Response(jsonEncode(createdTaskJson), 201);
      });
      TasksService.apiClient = ApiClient(client: mockClient);

      final future = taskProvider.createTask('New Task', 'low');
      
      // Let auth token retrieval complete and task be added
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Immediate state check (optimistic)
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].id, startsWith('temp_'));
      
      await future;

      // Final state check
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].id, 'real-id-1');
    });

    test('createTask reverts on failure', () async {
      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return http.Response('Server Error', 500);
      });
      TasksService.apiClient = ApiClient(client: mockClient);

      final future = taskProvider.createTask('Failed Task', 'low');
      await Future.delayed(const Duration(milliseconds: 10));
      expect(taskProvider.tasks.length, 1); // Optimistically added
      
      try {
        await future;
      } catch (_) {}

      expect(taskProvider.tasks, isEmpty);
      expect(taskProvider.errorMessage, contains('Failed to create task'));
    });

    test('markTaskAsComplete performs optimistic update', () async {
      final now = DateTime.now();
      final task = Task(
        id: '1',
        userId: 'u1',
        title: 'Task 1',
        description: 'First',
        priority: 'low',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      
      final mockClient = MockClient((request) async {
        if (request.method == 'PUT') {
           await Future.delayed(const Duration(milliseconds: 50));
           return http.Response(jsonEncode(task.toJson()..['isCompleted'] = true), 200);
        }
        return http.Response(jsonEncode([task.toJson()]), 200);
      });
      TasksService.apiClient = ApiClient(client: mockClient);

      await taskProvider.fetchTasks();
      expect(taskProvider.tasks[0].isCompleted, isFalse);

      final future = taskProvider.markTaskAsComplete('1');
      
      // Let auth token retrieval complete
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Optimistic check
      expect(taskProvider.tasks[0].isCompleted, isTrue);

      await future;
      expect(taskProvider.tasks[0].isCompleted, isTrue);
    });

    test('deleteTask performs optimistic removal and reverts on failure', () async {
      final now = DateTime.now();
      final task = Task(
        id: '1',
        userId: 'u1',
        title: 'Task 1',
        description: 'First',
        priority: 'low',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      
      bool failDelete = true;
      final mockClient = MockClient((request) async {
        if (request.method == 'DELETE') {
           await Future.delayed(const Duration(milliseconds: 50));
           if (failDelete) return http.Response('Error', 500);
           return http.Response('OK', 200);
        }
        return http.Response(jsonEncode([task.toJson()]), 200);
      });
      TasksService.apiClient = ApiClient(client: mockClient);

      await taskProvider.fetchTasks();
      expect(taskProvider.tasks.length, 1);

      // 1. Failure scenario
      final deleteFuture = taskProvider.deleteTask('1');
      await Future.delayed(const Duration(milliseconds: 10)); // Let auth retrieval happen and removal happen
      expect(taskProvider.tasks, isEmpty, reason: 'Should be optimistically removed');
      
      await deleteFuture;
      expect(taskProvider.tasks.length, 1, reason: 'Should have reverted back to 1 task on failure');
      expect(taskProvider.errorMessage, contains('Failed to delete task'));

      // 2. Success scenario
      failDelete = false;
      await taskProvider.deleteTask('1');
      expect(taskProvider.tasks, isEmpty);
    });

    test('reorderTasks updates local state', () async {
      final now = DateTime.now();
      final task1 = Task(
        id: '1',
        userId: 'u1',
        title: 'Title 1',
        description: 'First',
        priority: 'low',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      final task2 = Task(
        id: '2',
        userId: 'u1',
        title: 'Title 2',
        description: 'Second',
        priority: 'high',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode([task1.toJson(), task2.toJson()]), 200);
      });
      TasksService.apiClient = ApiClient(client: mockClient);

      await taskProvider.fetchTasks();
      expect(taskProvider.tasks[0].id, '1');

      taskProvider.reorderTasks(0, 2);
      expect(taskProvider.tasks[0].id, '2');
      expect(taskProvider.tasks[1].id, '1');
    });

    test('filtering tasks correctly interacts with API', () async {
      final now = DateTime.now();
      final activeTask = Task(
        id: '1',
        userId: 'u1',
        title: 'Title 1',
        description: 'Active',
        priority: 'low',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
      final completedTask = Task(
        id: '2',
        userId: 'u1',
        title: 'Title 2',
        description: 'Completed',
        priority: 'low',
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      mockAuthService.setLoginState(true, userId: 'u1', token: 't1');
      
      final mockClient = MockClient((request) async {
        final query = request.url.queryParameters;
        if (query['completed'] == 'true') {
          return http.Response(jsonEncode([completedTask.toJson()]), 200);
        } else if (query['completed'] == 'false') {
          return http.Response(jsonEncode([activeTask.toJson()]), 200);
        } else {
          return http.Response(jsonEncode([activeTask.toJson(), completedTask.toJson()]), 200);
        }
      });
      
      TasksService.apiClient = ApiClient(client: mockClient);

      await taskProvider.fetchTasks(forceRefresh: true);
      expect(taskProvider.tasks.length, 2);

      taskProvider.setFilter(TaskFilter.active);
      await Future.delayed(const Duration(milliseconds: 50)); 
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].description, 'Active');

      taskProvider.setFilter(TaskFilter.completed);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].description, 'Completed');
    });
  });
}
