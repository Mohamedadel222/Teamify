import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/core/di/service_locator.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:teamify/features/auth/presentation/cubit/login_cubit.dart';
import 'package:teamify/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:teamify/features/auth/presentation/screens/register_screen.dart';
import 'package:teamify/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:teamify/features/auth/presentation/screens/otp_screen.dart';
import 'package:teamify/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:teamify/features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/choose_role_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String chooseRole = '/chooseRole';
  static const String projects = '/projects';
  static const String home = '/home';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String otpVerification = '/otpVerification';
  static const String resetPassword = '/resetPassword';
  static const String verifyEmail = '/verifyEmail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );

        case register:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<AuthCubit>(),
              child: const RegisterScreen(),
            ),
          );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case chooseRole:
        return MaterialPageRoute(
          builder: (_) => const ChooseRoleScreen(),
        );

      case projects:
        return MaterialPageRoute(
          builder: (_) => const ProjectsScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<PasswordResetCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        );

      case otpVerification:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<PasswordResetCubit>(),
            child: OtpScreen(email: email),
          ),
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<PasswordResetCubit>(),
            child: const ResetPasswordScreen(),
          ),
        );

      case verifyEmail:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: email),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("No Route Found"),
            ),
          ),
        );
    }
  }
}