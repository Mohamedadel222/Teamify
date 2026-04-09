import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

class AppleLoginUseCase {
  Future<Either<Failure, User>> call() async {
    return Left(ServerFailure('Social login is not supported yet'));
  }
}