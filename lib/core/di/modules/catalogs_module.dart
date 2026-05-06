import '../service_locator.dart';
import '../../../features/catalogs/domain/repositories/i_catalogs_repository.dart';
import '../../../features/catalogs/infrastructure/datasources/catalogs_remote_datasource.dart';
import '../../../features/catalogs/infrastructure/repositories/catalogs_repository_impl.dart';
import '../../../features/catalogs/application/usecases/get_sports_usecase.dart' as cat_sports;
import '../../../features/catalogs/application/usecases/get_regions_usecase.dart';
import '../../../features/catalogs/application/usecases/get_canchas_usecase.dart';
import '../../../features/catalogs/application/usecases/create_cancha_usecase.dart';
import '../../../features/catalogs/infrastructure/services/location_service.dart';
import '../../../features/catalogs/presentation/bloc/add_court/add_court_bloc.dart';

Future<void> initCatalogs() async {
  // Data sources
  sl.registerLazySingleton<CatalogsRemoteDataSource>(() => CatalogsRemoteDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<ICatalogsRepository>(() => CatalogsRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => LocationService(dio: sl()));
  sl.registerLazySingleton(() => cat_sports.GetSportsUseCase(sl()));
  sl.registerLazySingleton(() => GetRegionsUseCase(sl()));
  sl.registerLazySingleton(() => GetCanchasUseCase(sl()));
  sl.registerLazySingleton(() => CreateCanchaUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AddCourtBloc(
      locationService: sl(),
      createCanchaUseCase: sl(),
    ),
  );
}
