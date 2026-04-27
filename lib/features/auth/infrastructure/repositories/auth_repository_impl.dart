import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final token = await remoteDataSource.signInWithGoogle();
      if (token != null) {
        debugPrint("✅ JWT RECIBIDO DE GOOGLE: $token");
        return const Right(
          UserModel(
            id: 'temp_id',
            email: 'google_user@matchday.com',
            name: 'Jugador Google',
          ),
        );
      } else {
        return const Left(
          AuthFailure('Inicio de sesión cancelado por el usuario'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final token = await remoteDataSource.loginUser(email, password);
      debugPrint("✅ JWT RECIBIDO EN LOGIN: $token");
      return Right(UserModel(id: 'temp_id', email: email, name: 'Jugador'));
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final token = await remoteDataSource.registerUser(name, email, password);
      debugPrint("✅ JWT RECIBIDO EN REGISTRO: $token");
      return Right(UserModel(id: 'temp_id', email: email, name: name));
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(token, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
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
