import 'package:dartz/dartz.dart';
import 'package:teamify/core/errors/failures.dart';

// import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase  {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  // @override
  Future<Either<Failure, User>> call(LoginParams params) {
  return repository.login(
    email: params.email,
    password: params.password,
  );
}
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

