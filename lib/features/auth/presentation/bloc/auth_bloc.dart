import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/sign_in_with_google_usecase.dart';
import '../../application/usecases/sign_in_with_email_usecase.dart';
import '../../application/usecases/register_usecase.dart';
import '../../application/usecases/forgot_password_usecase.dart';
import '../../application/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthBloc({
    required this.signInWithGoogleUseCase,
    required this.signInWithEmailUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {
    // 1. Oyente para Google
    on<SignInWithGoogleButtonPressed>((event, emit) async {
      emit(AuthLoading());
      final result = await signInWithGoogleUseCase();
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // 2. Oyente para Login Clásico
    on<SignInWithEmailButtonPressed>((event, emit) async {
      emit(AuthLoading());

      if (event.email.isEmpty || event.password.isEmpty) {
        emit(AuthError('Por favor, llena todos los campos'));
        return;
      }

      final result = await signInWithEmailUseCase(event.email, event.password);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // 3. Oyente para Registro
    on<RegisterButtonPressed>((event, emit) async {
      emit(AuthLoading());

      if (event.name.isEmpty || event.email.isEmpty || event.password.isEmpty) {
        emit(AuthError('Todos los campos son obligatorios'));
        return;
      }

      final result = await registerUseCase(
        event.name,
        event.email,
        event.password,
      );
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // 4. Oyente para Solicitar Recuperar Contraseña
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());

      if (event.email.isEmpty) {
        emit(AuthError('Por favor, ingresa tu correo electrónico'));
        return;
      }

      final result = await forgotPasswordUseCase(event.email);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(
          AuthPasswordResetSent(
            'Si el correo está registrado, recibirás un enlace',
          ),
        ),
      );
    });

    // 5. Oyente para Enviar Nueva Contraseña (NUEVO)
    on<ResetPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());

      if (event.newPassword.isEmpty || event.token.isEmpty) {
        emit(AuthError('Error en los datos. Intenta nuevamente.'));
        return;
      }

      final result = await resetPasswordUseCase(event.token, event.newPassword);
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) =>
            emit(AuthPasswordResetSent('Contraseña actualizada exitosamente')),
      );
    });
  }
}
