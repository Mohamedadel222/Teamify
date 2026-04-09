import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_guard_cubit.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:teamify/features/auth/presentation/screens/choose_role_screen.dart';
// import 'package:teamify/features/auth/presentation/screens/register_screen.dart';
// import 'package:teamify/features/onboarding/presentation/screens2/onboarding_screen.dart';
// import 'package:teamify/features/projects/presentation/screens/projects_screen.dart';
// import 'package:teamify/features/splash/presentation/screens/splash_screen.dart';

// import 'core/network/api_client.dart';
// import 'core/network/token_storage.dart';
// import 'features/auth/data/datasource/auth_remote_datasource.dart';
// import 'features/auth/data/repositories/auth_repository_impl.dart';
// import 'features/auth/domain/usecases/login_usecase.dart';
// import 'features/auth/presentation/provider/auth_provider.dart';
// import 'features/auth/presentation/screens/login_screen.dart';
// import 'features/home/presentation/home_screen.dart';

import 'core/routing/app_router.dart';
import 'core/di/service_locator.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthGuardCubit>(
          create: (_) => sl<AuthGuardCubit>()..checkAuth(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
  