abstract class AuthEvent {}

class SignInWithGoogleButtonPressed extends AuthEvent {}

class SignOutButtonPressed extends AuthEvent {}

class SignInWithEmailButtonPressed extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailButtonPressed({required this.email, required this.password});
}