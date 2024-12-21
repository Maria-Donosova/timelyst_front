class Calendar {
  final String id;
  final String summary;
  final String description;

  Calendar({
    required this.id,
    required this.summary,
    required this.description,
  });

  // Convert JSON to Calendar object
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'],
      summary: json['summary'],
      description: json['description'],
    );
  }

  // Convert Calendar object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'description': description,
    };
  }
}
