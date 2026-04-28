import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

class GetNotificationsUseCase {
  final INotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call() async {
    return await repository.getNotifications();
  }
}
