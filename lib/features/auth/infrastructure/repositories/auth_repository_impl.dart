import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart'; // Importamos el modelo

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Dio dio = Dio(); // Dio para conectarnos a Render

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final idToken = await remoteDataSource.signInWithGoogle();
      
      if (idToken != null) {
        // Apuntamos a la API pública de Render
        String baseUrl = 'https://matchday-backend-3qot.onrender.com';

        debugPrint("🚀 Enviando petición al backend en Render: $baseUrl/api/v1/auth/google");
        
        final response = await dio.post(
          '$baseUrl/api/v1/auth/google',
          data: {
            "id_token": idToken,
          },
        );

        final accessToken = response.data['access_token'];
        debugPrint("✅ RENDER RESPONDIÓ JWT: $accessToken");

        final userModel = const UserModel(
          id: '123', 
          email: 'usuario@gmail.com', 
          name: 'Jugador Google'
        );
        return Right(userModel);
      } else {
        return const Left(AuthFailure('Inicio de sesión cancelado por el usuario'));
      }
    } on DioException catch (e) {
      debugPrint("❌ Error de Dio conectando a Render: ${e.response?.data ?? e.message}");
      return Left(ServerFailure('Error en el Backend: ${e.response?.data ?? e.message}'));
    } catch (e) {
      debugPrint("❌ Error inesperado: $e");
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