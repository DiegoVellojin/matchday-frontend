import '../service_locator.dart';
import '../../../features/profile/application/usecases/get_user_profile_usecase.dart';
import '../../../features/profile/application/usecases/update_user_profile_usecase.dart';
import '../../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../../features/profile/infrastructure/datasources/profile_remote_data_source.dart';
import '../../../features/profile/infrastructure/repositories/profile_repository_impl.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart';

Future<void> initProfile() async {
  // Data sources
  sl.registerLazySingleton(() => ProfileRemoteDataSource(networkRobot: sl()));

  // Repository
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      secureStorageService: sl(),
    ),
  );
}
