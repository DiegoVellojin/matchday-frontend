import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Caso de uso que orquesta el inicio de sesión o registro mediante Google.
/// 
/// Llama al repositorio de autenticación para interactuar con los Google Play Services
/// e intercambiar el idToken con el backend.
class SignInWithGoogleUseCase {
  final IAuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}