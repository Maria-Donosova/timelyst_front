class Task {
  final String id;
  final String title;
  final String task_type;
  final String category;
  //final Color category;
  final DateTime dateCreated;
  final DateTime dateChanged;
  final String creator;

  Task({
    required this.id,
    required this.title,
    this.task_type = "Task",
    this.category = 'Work',
    //this.category = Colors.grey,
    required this.dateCreated,
    required this.dateChanged,
    required this.creator,
  });
}


//Task type for models to be amended once lists and notes/photos implmemented
//Consider amending category colory to allow dynamic assignment of color values (by user) 