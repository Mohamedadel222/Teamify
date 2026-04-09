import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
}