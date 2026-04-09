import 'package:dartz/dartz.dart';
import 'package:teamify/core/errors/failures.dart';
import 'package:teamify/features/projects/domain/entities/project.dart';
import 'package:teamify/features/projects/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<Either<Failure, List<Project>>> call() {
    return repository.getProjects();
  }
}