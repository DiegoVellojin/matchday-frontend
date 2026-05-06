import '../service_locator.dart';
import '../../../features/matches/domain/repositories/matches_repository.dart';
import '../../../features/matches/infrastructure/datasources/matches_remote_datasource.dart';
import '../../../features/matches/infrastructure/repositories/matches_repository_impl.dart';
import '../../../features/matches/application/usecases/matches_usecases.dart';
import '../../../features/matches/presentation/bloc/matches_bloc.dart';

Future<void> initMatches() async {
  // Data sources
  sl.registerLazySingleton<MatchesRemoteDataSource>(() => MatchesRemoteDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<IMatchesRepository>(() => MatchesRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetMatchesUseCase(sl()));
  sl.registerLazySingleton(() => GetMatchDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreateMatchUseCase(sl()));
  sl.registerLazySingleton(() => AcceptEncounterUseCase(sl()));
  sl.registerLazySingleton(() => ProposeTermsUseCase(sl()));
  sl.registerLazySingleton(() => JoinMatchUseCase(sl()));
  sl.registerLazySingleton(() => ConfigureMatchUseCase(sl()));
  sl.registerLazySingleton(() => MarkTeamReadyUseCase(sl()));
  sl.registerLazySingleton(() => RegisterMatchResultUseCase(sl()));
  sl.registerLazySingleton(() => CancelMatchUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMatchUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => MatchesBloc(
      getMatchesUseCase: sl(),
      getMatchDetailsUseCase: sl(),
      createMatchUseCase: sl(),
      proposeTermsUseCase: sl(),
      configureMatchUseCase: sl(),
      markTeamReadyUseCase: sl(),
      registerMatchResultUseCase: sl(),
      acceptEncounterUseCase: sl(),
      cancelMatchUseCase: sl(),
      updateMatchUseCase: sl(),
    ),
  );
}
