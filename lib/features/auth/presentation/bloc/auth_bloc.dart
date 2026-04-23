import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/sign_in_with_google_usecase.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  AuthBloc({required this.signInWithGoogleUseCase}) : super(AuthInitial()) {
    
    // 1. Oyente para Google
    on<SignInWithGoogleButtonPressed>((event, emit) async {
      emit(AuthLoading());
      final result = await signInWithGoogleUseCase(); 
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // 2. Oyente para Login Clásico (Correo/Clave)
    on<SignInWithEmailButtonPressed>((event, emit) async {
      emit(AuthLoading());
      
      // TODO: Aquí llamaremos al SignInWithEmailUseCase. Por ahora, simulamos el backend:
      await Future.delayed(const Duration(seconds: 2)); 
      
      if (event.email.isNotEmpty && event.password.isNotEmpty) {
        emit(AuthAuthenticated(const UserEntity(id: '999', email: 'test@matchday.com', name: 'Jugador Pro')));
      } else {
        emit(AuthError('Por favor, llena todos los campos'));
      }
    });
    
  }
}