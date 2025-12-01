class User {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String roleId;
  final bool consent;
  final Map<String, dynamic>? googleAccounts;
  final Map<String, dynamic>? microsoftAccounts;
  final Map<String, dynamic>? appleAccounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.roleId,
    required this.consent,
    this.googleAccounts,
    this.microsoftAccounts,
    this.appleAccounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      lastName: json['lastName'],
      roleId: json['roleId'],
      consent: json['consent'],
      googleAccounts: json['googleAccounts'],
      microsoftAccounts: json['microsoftAccounts'],
      appleAccounts: json['appleAccounts'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastName': lastName,
      'roleId': roleId,
      'consent': consent,
      'googleAccounts': googleAccounts,
      'microsoftAccounts': microsoftAccounts,
      'appleAccounts': appleAccounts,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }
}
