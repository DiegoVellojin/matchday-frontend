import '../service_locator.dart';
import '../../../features/payments/application/usecases/get_my_payments_usecase.dart';
import '../../../features/payments/application/usecases/upload_receipt_usecase.dart';
import '../../../features/payments/application/usecases/verify_user_payment_usecase.dart';
import '../../../features/payments/domain/repositories/i_payments_repository.dart';
import '../../../features/payments/infrastructure/datasources/payments_remote_data_source.dart';
import '../../../features/payments/infrastructure/repositories/payments_repository_impl.dart';
import '../../../features/payments/presentation/bloc/payments_bloc.dart';

Future<void> initPayments() async {
  // Data sources
  sl.registerLazySingleton(() => PaymentsRemoteDataSource(sl()));

  // Repository
  sl.registerLazySingleton<IPaymentsRepository>(() => PaymentsRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetMyPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadReceiptUseCase(sl()));
  sl.registerLazySingleton(() => VerifyUserPaymentUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => PaymentsBloc(
      getMyPaymentsUseCase: sl(),
      uploadReceiptUseCase: sl(),
      verifyUserPaymentUseCase: sl(),
    ),
  );
}
