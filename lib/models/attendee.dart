class Attendee {
  final String email;
  final String? name;
  final String status; // 'accepted', 'declined', 'tentative', 'needsAction'
  final bool isOrganizer;
  final bool isOptional;

  Attendee({
    required this.email,
    this.name,
    required this.status,
    this.isOrganizer = false,
    this.isOptional = false,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      email: json['email'] ?? '',
      name: json['name'],
      status: json['status'] ?? 'needsAction',
      isOrganizer: json['isOrganizer'] ?? json['is_organizer'] ?? false,
      isOptional: json['isOptional'] ?? json['is_optional'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'status': status,
      'isOrganizer': isOrganizer,
      'isOptional': isOptional,
    };
  }
}
