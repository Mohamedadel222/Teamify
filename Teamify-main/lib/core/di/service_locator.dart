import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:teamify/core/network/api_client.dart';
import 'package:teamify/core/storage/token_storage.dart';
// import 'package:teamify/features/auth/data/google_auth_service.dart';
import 'package:teamify/features/auth/domain/usecases/AppleLoginUseCase.dart';
import 'package:teamify/features/auth/domain/usecases/GitHubLoginUseCase.dart';
import 'package:teamify/features/auth/domain/usecases/GoogleLoginUseCase.dart';
import 'package:teamify/features/auth/domain/usecases/LinkedinLoginUseCase.dart';
import 'package:teamify/features/auth/presentation/cubit/login_cubit.dart';
import '../network/dio_client.dart';

// Auth Feature
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_guard_cubit.dart';
import '../../features/auth/presentation/cubit/password_reset_cubit.dart';

// Projects Feature
import 'package:teamify/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:teamify/features/projects/data/repositories/project_repository_impl.dart';
import 'package:teamify/features/projects/domain/repositories/project_repository.dart';
import 'package:teamify/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:teamify/features/projects/presentation/cubit/projects_cubit.dart';

final sl = GetIt.instance;
    // بدون هذين السطرين، عندما يصل البرنامج لسطر `sl<SharedPreferences>()` داخل تعريف الـ `TokenStorage` سيعطيك الخطأ (Bad State) لأنك تطلب شيء لم تضعه في الحقيبة (`GetIt`).

Future<void> init() async {
final sharedPrefs = await SharedPreferences.getInstance();
  /// ------------------ Core ------------------
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  // Dio
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // ApiClient
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<TokenStorage>()),
  );

  // Flutter Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Token Storage
  sl.registerLazySingleton<TokenStorage>(
    () => TokenStorage(sl<FlutterSecureStorage>(), sl<SharedPreferences>()),
  );

  /// ------------------ Auth ------------------
  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<TokenStorage>(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl<TokenStorage>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));


  // 🔥 Social Login UseCases (stubs — not supported yet)
  sl.registerLazySingleton(() => GoogleLoginUseCase());
  sl.registerLazySingleton(() => GitHubLoginUseCase());
  sl.registerLazySingleton(() => LinkedInLoginUseCase());
  sl.registerLazySingleton(() => AppleLoginUseCase());


  // Cubits
  sl.registerFactory(() => AuthCubit(sl<RegisterUseCase>()));
  sl.registerLazySingleton(() => PasswordResetCubit(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthGuardCubit(sl<CheckAuthUseCase>(), sl<LogoutUseCase>()),
  );

  sl.registerFactory(
  () => LoginCubit(sl<LoginUseCase>(), sl<TokenStorage>(), sl<GoogleLoginUseCase>(), sl<GitHubLoginUseCase>(), sl<LinkedInLoginUseCase>(), sl<AppleLoginUseCase>())

  
);

  /// ------------------ Projects ------------------
  // Data Source
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(sl<ProjectRemoteDataSource>()),
  );

  // UseCase
  sl.registerLazySingleton(() => GetProjectsUseCase(sl<ProjectRepository>()));

  // Cubit
  sl.registerFactory(() => ProjectsCubit(sl<GetProjectsUseCase>()));
}
