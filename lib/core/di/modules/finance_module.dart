import '../../../features/finance/domain/repositories/i_finance_repository.dart';
import '../../../features/finance/infrastructure/repositories/finance_repository_impl.dart';
import '../../../features/config/presentation/bloc/config_bloc.dart';
import '../service_locator.dart';

Future<void> initFinance() async {
  // Repositories
  sl.registerLazySingleton<IFinanceRepository>(
    () => FinanceRepositoryImpl(sl()),
  );

  // Blocs
  sl.registerLazySingleton(() => ConfigBloc(sl()));
}
