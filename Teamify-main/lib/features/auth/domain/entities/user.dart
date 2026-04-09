import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String? fullName;
  final String? userType;
  final String? createdAt;

  const User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.fullName,
    this.userType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, displayName, email, role];
}