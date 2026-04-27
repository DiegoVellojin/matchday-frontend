import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class IAuthRepository {
  /// Retorna un UserEntity si el login con Google es exitoso, o un Failure si algo falla.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Inicia sesión con correo y contraseña.
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Registra un nuevo usuario (el backend acepta el teléfono como null).
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  );

  /// Solicita el correo de recuperación de contraseña.
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Envía la nueva contraseña usando el token del correo.
  Future<Either<Failure, void>> resetPassword(String token, String newPassword);

  /// Cierra la sesión activa.
  Future<Either<Failure, void>> signOut();
}
