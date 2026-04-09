import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_guard_cubit.dart';
import 'package:teamify/features/auth/presentation/cubit/login_cubit.dart';
// import 'package:teamify/features/auth/domain/entities/user.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<LoginCubit>().state is AuthSuccess)
        ? (context.read<LoginCubit>().state as AuthSuccess).user
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text("Home - ${user?.displayName ?? 'Guest'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: "Go to Login (without clearing data)",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthGuardCubit>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Logout (clear data)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Go to Login (without clearing data)"),
            ),
          ],
        ),
      ),
    );
  }
}