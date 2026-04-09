import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final GetProjectsUseCase getProjectsUseCase;

  ProjectsCubit(this.getProjectsUseCase)
      : super(ProjectsInitial());

  Future<void> fetchProjects() async {
    emit(ProjectsLoading());

    final result = await getProjectsUseCase();

    result.fold(
      (failure) => emit(ProjectsError(failure.message)),
      (projects) => emit(ProjectsLoaded(projects)),
    );
  }
}