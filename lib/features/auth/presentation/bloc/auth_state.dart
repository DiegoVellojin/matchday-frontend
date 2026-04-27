import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// NUEVO: Estado para cuando el correo de recuperación se envía con éxito
class AuthPasswordResetSent extends AuthState {
  final String message;
  AuthPasswordResetSent(this.message);
}
