import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/models/task.dart';

void main() {
  group('Task Model Serialization', () {
    test('toJson converts dates to UTC', () {
      final task = Task(
        id: 'test-id',
        userId: 'user-123',
        title: 'Test Task',
        description: 'Do something',
        dueDate: DateTime.parse('2023-01-01T15:00:00'),
        isCompleted: false,
        priority: 'HIGH',
        createdAt: DateTime.parse('2023-01-01T10:00:00'),
        updatedAt: DateTime.parse('2023-01-01T11:00:00'),
      );

      final json = task.toJson();

      expect(json['dueDate'], endsWith('Z'));
      expect(json['createdAt'], endsWith('Z'));
      expect(json['updatedAt'], endsWith('Z'));
    });
  });
}
