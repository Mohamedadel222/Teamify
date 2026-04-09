import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class OtpSent extends PasswordResetState {
  final String message;
  OtpSent(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpVerified extends PasswordResetState {
  final String resetToken;
  OtpVerified(this.resetToken);
  @override
  List<Object?> get props => [resetToken];
}

class PasswordResetSuccess extends PasswordResetState {}

class PasswordResetError extends PasswordResetState {
  final String message;
  PasswordResetError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class PasswordResetCubit extends Cubit<PasswordResetState> {
  final AuthRepository repository;

  String _email = '';
  String _resetToken = '';

  String get email => _email;
  String get resetToken => _resetToken;

  PasswordResetCubit(this.repository) : super(PasswordResetInitial());

  Future<void> forgotPassword({required String email}) async {
    emit(PasswordResetLoading());
    _email = email;

    final result = await repository.forgotPassword(email: email);
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (message) => emit(OtpSent(message)),
    );
  }

  Future<void> verifyOtp({required String otp}) async {
    emit(PasswordResetLoading());

    final result = await repository.verifyOtp(email: _email, otp: otp);
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (resetToken) {
        _resetToken = resetToken;
        emit(OtpVerified(resetToken));
      },
    );
  }

  Future<void> resetPassword({required String newPassword}) async {
    emit(PasswordResetLoading());

    final result = await repository.resetPassword(
      resetToken: _resetToken,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(PasswordResetError(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
