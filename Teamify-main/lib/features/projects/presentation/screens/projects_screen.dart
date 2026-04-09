import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/projects_cubit.dart';
import '../cubit/projects_state.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProjectsCubit>()..fetchProjects(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Projects"),
        ),
        body: BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) {
            if (state is ProjectsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProjectsLoaded) {
              return ListView.builder(
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];

                  return ListTile(
                    title: Text(project.name),
                    subtitle: Text(project.description),
                  );
                },
              );
            }

            if (state is ProjectsError) {
              return Center(
                child: Text(state.message),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}