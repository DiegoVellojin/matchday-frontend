import '../service_locator.dart';
import '../../../features/notifications/application/usecases/get_notifications_usecase.dart';
import '../../../features/notifications/application/usecases/mark_notification_as_read_usecase.dart';
import '../../../features/notifications/application/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../../features/notifications/infrastructure/datasources/notification_remote_data_source.dart';
import '../../../features/notifications/infrastructure/repositories/notification_repository_impl.dart';
import '../../../features/notifications/presentation/bloc/notifications_bloc.dart';

Future<void> initNotifications() async {
  // Data sources
  sl.registerLazySingleton(() => NotificationRemoteDataSource(networkRobot: sl()));

  // Repository
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => NotificationsBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
    ),
  );
}
