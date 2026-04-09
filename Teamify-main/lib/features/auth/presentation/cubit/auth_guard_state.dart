import 'package:equatable/equatable.dart';

abstract class AuthGuardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthGuardInitial extends AuthGuardState {}

class AuthAuthenticated extends AuthGuardState {}

class AuthUnauthenticated extends AuthGuardState {}

class AuthFirstTimeUser extends AuthGuardState {}