import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


// Importaciones Core
import '../network/network_robot.dart';
import '../theme/bloc/theme_bloc.dart';
import '../storage/secure_storage_service.dart';
import '../storage/firebase_storage_service.dart';


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
import '../../features/teams_discovery/application/usecases/respond_to_join_request_usecase.dart';
import '../../features/teams_discovery/application/usecases/get_sports_usecase.dart';
import '../../features/teams_discovery/application/usecases/update_team_usecase.dart';
import '../../features/teams_discovery/application/usecases/delete_team_usecase.dart';
import '../../features/teams_discovery/application/usecases/transfer_captain_usecase.dart';
import '../../features/teams_discovery/application/usecases/leave_team_usecase.dart';
import '../../features/teams_discovery/application/usecases/kick_member_usecase.dart' as discovery_kick;





import '../../features/teams_discovery/domain/repositories/i_teams_discovery_repository.dart';
import '../../features/teams_discovery/infrastructure/datasources/teams_discovery_remote_data_source.dart';
import '../../features/teams_discovery/infrastructure/repositories/teams_discovery_repository_impl.dart';
import '../../features/teams_discovery/presentation/bloc/teams_discovery_bloc.dart';

// Importaciones de Notificaciones (NUEVO)
import '../../features/notifications/application/usecases/get_notifications_usecase.dart';
import '../../features/notifications/application/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notifications/application/usecases/mark_all_notifications_as_read_usecase.dart';

import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/infrastructure/datasources/notification_remote_data_source.dart';
import '../../features/notifications/infrastructure/repositories/notification_repository_impl.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

// Importaciones de Perfil (NUEVO)
import '../../features/profile/application/usecases/get_user_profile_usecase.dart';
import '../../features/profile/application/usecases/update_user_profile_usecase.dart';

import '../../features/profile/domain/repositories/i_profile_repository.dart';

import '../../features/profile/infrastructure/datasources/profile_remote_data_source.dart';
import '../../features/profile/infrastructure/repositories/profile_repository_impl.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
// Importaciones de Mis Equipos (NUEVO)
import '../../features/my_teams/application/usecases/get_my_teams_usecase.dart' as mt_usecase;

import '../../features/my_teams/application/usecases/kick_member_usecase.dart';
import '../../features/my_teams/domain/repositories/i_my_teams_repository.dart';
import '../../features/my_teams/infrastructure/datasources/my_teams_remote_datasource.dart';
import '../../features/my_teams/infrastructure/repositories/my_teams_repository_impl.dart';
import '../../features/my_teams/presentation/bloc/my_teams_bloc.dart';

// Importaciones de Pagos (NUEVO)
import '../../features/payments/application/usecases/get_my_payments_usecase.dart';
import '../../features/payments/application/usecases/upload_receipt_usecase.dart';
import '../../features/payments/domain/repositories/i_payments_repository.dart';
import '../../features/payments/infrastructure/datasources/payments_remote_data_source.dart';
import '../../features/payments/infrastructure/repositories/payments_repository_impl.dart';
import '../../features/payments/presentation/bloc/payments_bloc.dart';


// sl = Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ===========================================================================
  // 5. CORE & PAQUETES EXTERNOS
  // ===========================================================================
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(),
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

  // Perfil
  sl.registerLazySingleton(
    () => ProfileRemoteDataSource(networkRobot: sl()),
  );

  // Mis Equipos (NUEVO)
  sl.registerLazySingleton(() => MyTeamsRemoteDataSource(sl()));

  // Pagos (NUEVO)
  sl.registerLazySingleton(() => PaymentsRemoteDataSource(sl()));



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

  // Perfil
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Mis Equipos (NUEVO)
  sl.registerLazySingleton<IMyTeamsRepository>(() => MyTeamsRepositoryImpl(sl()));

  // Pagos (NUEVO)
  sl.registerLazySingleton<IPaymentsRepository>(() => PaymentsRepositoryImpl(sl()));




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
  sl.registerLazySingleton(() => RespondToJoinRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetSportsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTeamUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTeamUseCase(sl()));
  sl.registerLazySingleton(() => TransferCaptainUseCase(sl()));
  sl.registerLazySingleton(() => LeaveTeamUseCase(sl()));
  sl.registerLazySingleton(() => discovery_kick.KickMemberUseCase(sl()));




  // Notificaciones
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));


  // Perfil
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));


  // Mis Equipos (NUEVO)
  sl.registerLazySingleton(() => mt_usecase.GetMyTeamsUseCase(sl()));
  sl.registerLazySingleton(() => KickMemberUseCase(sl()));

  // Pagos (NUEVO)
  sl.registerLazySingleton(() => GetMyPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadReceiptUseCase(sl()));





  // ===========================================================================
  // 1. BLOCs
  // ===========================================================================
  // Cargar el modo de tema guardado
  final secureStorage = SecureStorageService(const FlutterSecureStorage());
  final isDark = await secureStorage.isDarkMode();
  final initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  sl.registerLazySingleton(() => ThemeBloc(initialThemeMode, sl()));


  // Notificaciones
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),

    ),
  );

  // Perfil
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      secureStorageService: sl(),
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
    () => TeamsDiscoveryBloc(
      getTeamsUseCase: sl(),
      requestJoinUseCase: sl(),
      getSportsUseCase: sl(),
    ),
  );

  // Mis Equipos (NUEVO)
  sl.registerFactory(
    () => MyTeamsBloc(
      getMyTeamsUseCase: sl(),
      kickMemberUseCase: sl(),
    ),
  );

  // Pagos (NUEVO)
  sl.registerFactory(
    () => PaymentsBloc(
      getMyPaymentsUseCase: sl(),
      uploadReceiptUseCase: sl(),
    ),
  );


}
