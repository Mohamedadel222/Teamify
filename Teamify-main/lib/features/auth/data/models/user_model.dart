import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.role,
    super.fullName,
    super.userType,
    super.createdAt,
  });

  /// Parse the "user" object returned by the backend.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      fullName: json['full_name'],
      userType: json['user_type'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'role': role,
      'full_name': fullName,
      'user_type': userType,
    };
  }
}