import 'dart:ffi';

class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String lastName;
  final Bool consent;
  final tasks;
  final events;
  final String createdDate;
  final String modifiedDate;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.lastName,
    required this.consent,
    this.tasks,
    this.events,
    required this.createdDate,
    required this.modifiedDate,
  });
}

//add logic to handle admin role and different permission models: superadmin, admin, moderator?
