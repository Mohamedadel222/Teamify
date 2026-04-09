import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/core/storage/token_storage.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_guard_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/cubit/auth_guard_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthGuardCubit, AuthGuardState>(
      listener: (context, state) async {
        final token = await sl<TokenStorage>().getToken();
        if (kDebugMode) {
          print("TOKEN FROM STORAGE: $token");
        }

        if (state is AuthAuthenticated) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthFirstTimeUser) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else if (state is AuthUnauthenticated) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/login');
          (route) => false;
        }
      },
      child: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
