import '../service_locator.dart';
import '../../../features/teams/application/usecases/get_discoverable_teams_usecase.dart';
import '../../../features/teams/application/usecases/request_join_team_usecase.dart';
import '../../../features/teams/application/usecases/create_team_usecase.dart';
import '../../../features/teams/application/usecases/get_team_by_id_usecase.dart';
import '../../../features/teams/application/usecases/get_team_members_usecase.dart';
import '../../../features/teams/application/usecases/get_pending_requests_usecase.dart';
import '../../../features/teams/application/usecases/respond_to_join_request_usecase.dart';
import '../../../features/teams/application/usecases/get_sports_usecase.dart';
import '../../../features/teams/application/usecases/update_team_usecase.dart';
import '../../../features/teams/application/usecases/delete_team_usecase.dart';
import '../../../features/teams/application/usecases/transfer_captain_usecase.dart';
import '../../../features/teams/application/usecases/leave_team_usecase.dart';
import '../../../features/teams/application/usecases/kick_member_usecase.dart';
import '../../../features/teams/application/usecases/get_my_teams_usecase.dart';
import '../../../features/teams/domain/repositories/i_teams_repository.dart';
import '../../../features/teams/infrastructure/datasources/teams_remote_data_source.dart';
import '../../../features/teams/infrastructure/repositories/teams_repository_impl.dart';
import '../../../features/teams/presentation/bloc/teams_bloc.dart';
import '../../../features/teams/presentation/bloc/my_teams_bloc.dart';

Future<void> initTeams() async {
  // Data sources
  sl.registerLazySingleton(() => TeamsRemoteDataSource(networkRobot: sl()));

  // Repository
  sl.registerLazySingleton<ITeamsRepository>(
    () => TeamsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDiscoverableTeamsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyTeamsUseCase(sl()));
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
  sl.registerLazySingleton(() => KickMemberUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => TeamsBloc(
      getTeamsUseCase: sl(),
      requestJoinUseCase: sl(),
      getSportsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => MyTeamsBloc(
      getMyTeamsUseCase: sl(),
      kickMemberUseCase: sl(),
    ),
  );
}
