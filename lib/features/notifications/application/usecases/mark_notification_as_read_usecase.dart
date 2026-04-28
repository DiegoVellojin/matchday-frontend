import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final INotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
