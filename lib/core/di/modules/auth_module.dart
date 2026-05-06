import '../service_locator.dart';
import '../../../features/auth/application/usecases/sign_in_with_google_usecase.dart';
import '../../../features/auth/application/usecases/sign_in_with_email_usecase.dart';
import '../../../features/auth/application/usecases/register_usecase.dart';
import '../../../features/auth/application/usecases/forgot_password_usecase.dart';
import '../../../features/auth/application/usecases/reset_password_usecase.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import '../../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';

Future<void> initAuth() async {
  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(dio: sl()));

  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), secureStorageService: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // BLoC
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
