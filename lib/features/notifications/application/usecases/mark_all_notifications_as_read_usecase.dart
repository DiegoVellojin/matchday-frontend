import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_notification_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final INotificationRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllAsRead();
  }
}
