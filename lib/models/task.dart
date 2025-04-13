class Task {
  final String taskId;
  final String title;
  String status;
  final String task_type;
  final String category;

  Task({
    this.taskId = '',
    required this.title,
    required this.status,
    this.task_type = "Task",
    this.category = 'Work',
  });

  // Convert JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['id'],
      title: json['title'],
      status: json['status'],
      task_type: json['task_type'],
      category: json['category'],
    );
  }

  // Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'task_type': task_type,
      'category': category,
    };
  }
}
