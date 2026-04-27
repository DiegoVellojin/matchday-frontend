abstract class AuthEvent {}

class SignInWithGoogleButtonPressed extends AuthEvent {}

class SignOutButtonPressed extends AuthEvent {}

class SignInWithEmailButtonPressed extends AuthEvent {
  final String email;
  final String password;
  SignInWithEmailButtonPressed({required this.email, required this.password});
}

class RegisterButtonPressed extends AuthEvent {
  final String name;
  final String email;
  final String password;
  RegisterButtonPressed({
    required this.name,
    required this.email,
    required this.password,
  });
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested({required this.email});
}

class ResetPasswordSubmitted extends AuthEvent {
  final String token;
  final String newPassword;
  ResetPasswordSubmitted({required this.token, required this.newPassword});
}
