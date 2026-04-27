import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Importaciones Core
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/network_robot.dart';
import '../theme/bloc/theme_bloc.dart';
import '../storage/secure_storage_service.dart';

// Importaciones de Auth
import '../../features/auth/application/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/application/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/application/usecases/register_usecase.dart';
import '../../features/auth/application/usecases/forgot_password_usecase.dart';
import '../../features/auth/application/usecases/reset_password_usecase.dart'; // NUEVO

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// sl = Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // 5. CORE & PAQUETES EXTERNOS
  // ===========================================================================
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService(sl()));
  
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<NetworkRobot>(() => NetworkRobot(sl(), sl()));

  // ===========================================================================
  // 4. DATA SOURCES
  // ===========================================================================
  sl.registerLazySingleton(() => AuthRemoteDataSource(dio: sl()));

  // ===========================================================================
  // 3. REPOSITORIOS
  // ===========================================================================
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorageService: sl(),
    ),
  );

  // ===========================================================================
  // 2. CASOS DE USO
  // ===========================================================================
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // ===========================================================================
  // 1. BLOCs
  // ===========================================================================
  sl.registerLazySingleton(() => ThemeBloc());
  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogleUseCase: sl(),
      signInWithEmailUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
}
