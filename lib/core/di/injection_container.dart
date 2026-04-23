import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Importaciones Core
import '../network/network_robot.dart';
import '../theme/bloc/theme_bloc.dart';

// Importaciones de Auth
import '../../features/auth/application/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart'; 
import '../../features/auth/presentation/bloc/auth_bloc.dart'; 

// sl = Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // 1. BLOCs (Capa de Presentación)
  // ===========================================================================
  sl.registerLazySingleton(() => ThemeBloc());
  sl.registerFactory(() => AuthBloc(signInWithGoogleUseCase: sl()));

  // ===========================================================================
  // 2. CASOS DE USO (Capa de Aplicación)
  // ===========================================================================
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));

  // ===========================================================================
  // 3. REPOSITORIOS (Capa de Dominio/Infraestructura)
  // ===========================================================================
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ===========================================================================
  // 4. DATA SOURCES (Capa de Infraestructura)
  // ===========================================================================
  sl.registerLazySingleton(() => AuthRemoteDataSource());

  // ===========================================================================
  // 5. CORE & PAQUETES EXTERNOS
  // ===========================================================================
  // Registramos Dio
  sl.registerLazySingleton<Dio>(() => Dio());
  
  // Registramos nuestro Robot de red que utilizará el Dio inyectado
  sl.registerLazySingleton<NetworkRobot>(() => NetworkRobot(sl()));
}