import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  });

  Future<void> logout();

  Future<Either<Failure, String>> forgotPassword({required String email});

  Future<Either<Failure, String>> verifyOtp({required String email, required String otp});

  Future<Either<Failure, void>> resetPassword({required String resetToken, required String newPassword});
}




