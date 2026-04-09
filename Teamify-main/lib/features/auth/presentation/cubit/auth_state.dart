import 'package:equatable/equatable.dart';
import 'package:teamify/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}


class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final User user;


  AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}