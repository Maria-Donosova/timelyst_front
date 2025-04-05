class Task {
  final String id;
  final String title;
  String status;
  final String task_type;
  final String category;
  //final DateTime dateCreated;
  //final DateTime dateChanged;
  //final String creator;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.task_type = "Task",
    this.category = 'Work',
    //required this.dateCreated,
    //required this.dateChanged,
    //required this.creator,
  });

  // Convert JSON to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      task_type: json['task_type'],
      category: json['category'],
      //dateCreated: DateTime.parse(json['createdAt'] ?? json['dateCreated']),
      //dateChanged: DateTime.parse(json['updatedAt'] ?? json['dateChanged']),
      //creator: json['creator'],
    );
  }

  // Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'task_type': task_type,
      'category': category,
      //'createdAt': dateCreated.toIso8601String(),
      //'updatedAt': dateChanged.toIso8601String(),
      //'user_id': creator,
    };
  }
}
