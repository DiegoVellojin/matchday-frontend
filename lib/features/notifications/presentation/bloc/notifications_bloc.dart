import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/get_notifications_usecase.dart';
import '../../application/usecases/mark_notification_as_read_usecase.dart';
import '../../application/usecases/mark_all_notifications_as_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  }) : super(NotificationsInitial()) {

    on<LoadNotificationsEvent>((event, emit) async {
      emit(NotificationsLoading());
      final result = await getNotificationsUseCase();
      result.fold(
        (failure) => emit(NotificationsError(message: failure.message)),
        (notifications) => emit(NotificationsLoaded(notifications: notifications)),
      );
    });

    on<MarkNotificationAsReadEvent>((event, emit) async {
      final result = await markNotificationAsReadUseCase(event.notificationId);
      result.fold(
        (failure) => emit(NotificationsError(message: failure.message)),
        (_) {
          add(LoadNotificationsEvent());
        },
      );
    });

    on<MarkAllNotificationsAsReadEvent>((event, emit) async {
      final result = await markAllNotificationsAsReadUseCase();
      result.fold(
        (failure) => emit(NotificationsError(message: failure.message)),
        (_) {
          add(LoadNotificationsEvent());
        },
      );
    });

  }
}
