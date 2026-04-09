import 'package:dio/dio.dart';
import 'package:teamify/core/constants/app_constants.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
}

class ProjectRemoteDataSourceImpl
    implements ProjectRemoteDataSource {
  final Dio dio;

  ProjectRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProjectModel>> getProjects() async {
    final response = await dio.get(AppConstants.projectsPath);

    final List data = response.data['projects'] ?? [];

    return data
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }
}