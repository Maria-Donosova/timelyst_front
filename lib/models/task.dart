class Task {
  final String id;
  final String title;
  final String status;
  final String task_type;
  final String category;
  final DateTime dateCreated;
  final DateTime dateChanged;
  final String creator;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.task_type = "Task",
    this.category = 'Work',
    required this.dateCreated,
    required this.dateChanged,
    required this.creator,
  });

  // Convert JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      task_type: json['task_type'],
      category: json['category'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateChanged: DateTime.parse(json['dateChanged']),
      creator: json['creator'],
    );
  }

  // Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'task_type': task_type,
      'category': category,
      'dateCreated': dateCreated.toIso8601String(),
      'dateChanged': dateChanged.toIso8601String(),
      'creator': creator,
    };
  }
}

// class Task {
//   final String id;
//   final String title;
//   final String task_type;
//   final String category;
//   //final Color category;
//   final DateTime dateCreated;
//   final DateTime dateChanged;
//   final String creator;

//   Task({
//     required this.id,
//     required this.title,
//     this.task_type = "Task",
//     this.category = 'Work',
//     //this.category = Colors.grey,
//     required this.dateCreated,
//     required this.dateChanged,
//     required this.creator,
//   });
// }
