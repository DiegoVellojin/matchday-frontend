import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class IAuthRepository {
  /// Retorna un UserEntity si el login con Google es exitoso, o un Failure si algo falla.
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  
  /// Cierra la sesión activa
  Future<Either<Failure, void>> signOut();
}