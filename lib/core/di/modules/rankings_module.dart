import '../service_locator.dart';
import '../../../features/rankings/domain/repositories/i_rankings_repository.dart';
import '../../../features/rankings/infrastructure/datasources/rankings_remote_datasource.dart';
import '../../../features/rankings/infrastructure/repositories/rankings_repository_impl.dart';
import '../../../features/rankings/application/usecases/get_team_leaderboard_usecase.dart';
import '../../../features/rankings/application/usecases/get_evaluations_usecase.dart';
import '../../../features/rankings/presentation/bloc/leaderboard_bloc.dart';
import '../../../features/rankings/presentation/bloc/evaluations_bloc.dart';

Future<void> initRankings() async {
  // Data sources
  sl.registerLazySingleton(() => RankingsRemoteDataSource(sl()));

  // Repository
  sl.registerLazySingleton<IRankingsRepository>(() => RankingsRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetTeamLeaderboardUseCase(sl()));
  sl.registerLazySingleton(() => GetEvaluationsUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => LeaderboardBloc(getTeamLeaderboardUseCase: sl()),
  );
  sl.registerFactory(
    () => EvaluationsBloc(getEvaluationsUseCase: sl()),
  );
}
