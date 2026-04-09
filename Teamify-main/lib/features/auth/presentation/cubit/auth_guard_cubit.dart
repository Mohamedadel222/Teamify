import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:teamify/features/auth/domain/usecases/logout_usecase.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/di/service_locator.dart';
import 'auth_guard_state.dart';

class AuthGuardCubit extends Cubit<AuthGuardState> {
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;

  AuthGuardCubit(
    this.checkAuthUseCase,
    this.logoutUseCase,
  ) : super(AuthGuardInitial());

  Future<void> checkAuth() async {
    final isLoggedIn = await checkAuthUseCase();
    final seenOnboarding =
        await sl<TokenStorage>().isOnboardingSeen();

    if (isLoggedIn) {
      emit(AuthAuthenticated());
    } else if (!seenOnboarding) {
      emit(AuthFirstTimeUser());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}