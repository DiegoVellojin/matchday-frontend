import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Importaciones Core
import '../network/network_robot.dart';
import '../theme/bloc/theme_bloc.dart';
import '../storage/secure_storage_service.dart';

// Importaciones de Auth
import '../../features/auth/application/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/application/usecases/sign_in_with_email_usecase.dart';
import '../../features/auth/application/usecases/register_usecase.dart';
import '../../features/auth/application/usecases/forgot_password_usecase.dart';
import '../../features/auth/application/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Importaciones de Teams Discovery (NUEVO)
import '../../features/teams_discovery/application/usecases/get_discoverable_teams_usecase.dart';
import '../../features/teams_discovery/application/usecases/request_join_team_usecase.dart';
import '../../features/teams_discovery/application/usecases/create_team_usecase.dart';
import '../../features/teams_discovery/application/usecases/get_team_by_id_usecase.dart';
import '../../features/teams_discovery/application/usecases/get_team_members_usecase.dart';
import '../../features/teams_discovery/application/usecases/get_pending_requests_usecase.dart';



import '../../features/teams_discovery/domain/repositories/i_teams_discovery_repository.dart';
import '../../features/teams_discovery/infrastructure/datasources/teams_discovery_remote_data_source.dart';
import '../../features/teams_discovery/infrastructure/repositories/teams_discovery_repository_impl.dart';
import '../../features/teams_discovery/presentation/bloc/teams_discovery_bloc.dart';

// Importaciones de Notificaciones (NUEVO)
import '../../features/notifications/application/usecases/get_notifications_usecase.dart';
import '../../features/notifications/application/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/infrastructure/datasources/notification_remote_data_source.dart';
import '../../features/notifications/infrastructure/repositories/notification_repository_impl.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';


// sl = Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // 5. CORE & PAQUETES EXTERNOS
  // ===========================================================================
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl()),
  );

  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<NetworkRobot>(() => NetworkRobot(sl(), sl()));

  // ===========================================================================
  // 4. DATA SOURCES
  // ===========================================================================
  // Auth
  sl.registerLazySingleton(() => AuthRemoteDataSource(dio: sl()));

  // Teams Discovery (NUEVO)
  sl.registerLazySingleton(
    () => TeamsDiscoveryRemoteDataSource(networkRobot: sl()),
  );

  // Notificaciones
  sl.registerLazySingleton(
    () => NotificationRemoteDataSource(networkRobot: sl()),
  );

  // ===========================================================================
  // 3. REPOSITORIOS
  // ===========================================================================
  // Auth
  sl.registerLazySingleton<IAuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: sl(), secureStorageService: sl()),
  );

  // Teams Discovery (NUEVO)
  sl.registerLazySingleton<ITeamsDiscoveryRepository>(
    () => TeamsDiscoveryRepositoryImpl(remoteDataSource: sl()),
  );

  // Notificaciones
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );


  // ===========================================================================
  // 2. CASOS DE USO
  // ===========================================================================
  // Auth
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Teams Discovery (NUEVO)
  sl.registerLazySingleton(() => GetDiscoverableTeamsUseCase(sl()));
  sl.registerLazySingleton(() => RequestJoinTeamUseCase(sl()));
  sl.registerLazySingleton(() => CreateTeamUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamMembersUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingRequestsUseCase(sl()));



  // Notificaciones
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));

  // ===========================================================================
  // 1. BLOCs
  // ===========================================================================
  sl.registerLazySingleton(() => ThemeBloc());

  // Notificaciones
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
    ),
  );

  // Auth

  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogleUseCase: sl(),
      signInWithEmailUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );

  // Teams Discovery (NUEVO)
  sl.registerFactory(
    () => TeamsDiscoveryBloc(getTeamsUseCase: sl(), requestJoinUseCase: sl()),
  );
}
