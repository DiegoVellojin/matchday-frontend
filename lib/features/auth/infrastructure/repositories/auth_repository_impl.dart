import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart'; // Importamos el modelo

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final idToken = await remoteDataSource.signInWithGoogle();
      
      if (idToken != null) {
        // En lugar de usar UserEntity directamente, usamos UserModel.
        // Como UserModel extiende de UserEntity, cumple perfectamente el contrato.
        final userModel = const UserModel(
          id: '123', 
          email: 'usuario@gmail.com', 
          name: 'Jugador Google'
        );
        return Right(userModel);
      } else {
        return const Left(AuthFailure('Inicio de sesión cancelado por el usuario'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Error al cerrar sesión localmente'));
    }
  }
}