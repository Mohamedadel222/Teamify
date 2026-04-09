import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/features/auth/domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;

  AuthCubit(this.registerUseCase)
      : super(AuthInitial());

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  }) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      displayName: displayName,
      email: email,
      password: password,
      role: role,
      fullName: fullName,
      userType: userType,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }
}