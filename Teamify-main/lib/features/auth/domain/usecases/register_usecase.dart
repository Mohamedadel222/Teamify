import 'package:dartz/dartz.dart';
import 'package:teamify/core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  }) async {
    return repository.register(
      displayName: displayName,
      email: email,
      password: password,
      role: role,
      fullName: fullName,
      userType: userType,
    );
  }
}

class RegisterParams {
  final String displayName;
  final String email;
  final String password;
  final String role;
  final String? fullName;
  final String? userType;

  RegisterParams({
    required this.displayName,
    required this.email,
    required this.password,
    required this.role,
    this.fullName,
    this.userType,
  });
}