import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<Either<Failure, User>> register({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  }) async {
    try {
      final authResponse = await remoteDataSource.register(
        displayName: displayName,
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        userType: userType,
      );

      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return Right(authResponse.user);
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return Right(authResponse.user);
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearAll();
  }

  @override
  Future<Either<Failure, String>> forgotPassword({required String email}) async {
    try {
      final message = await remoteDataSource.forgotPassword(email: email);
      return Right(message);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({required String email, required String otp}) async {
    try {
      final resetToken = await remoteDataSource.verifyOtp(email: email, otp: otp);
      return Right(resetToken);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String resetToken, required String newPassword}) async {
    try {
      await remoteDataSource.resetPassword(resetToken: resetToken, newPassword: newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Extract a human-readable error message from the backend response.
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      // Backend returns {"error": "...", "message": "..."} or {"messages": [...]}
      if (data.containsKey('message')) return data['message'];
      if (data.containsKey('messages')) {
        final msgs = data['messages'];
        if (msgs is List) return msgs.join(', ');
      }
      if (data.containsKey('error')) return data['error'];
    }
    return e.message ?? 'Server Error';
  }
}
