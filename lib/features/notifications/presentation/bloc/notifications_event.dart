abstract class NotificationsEvent {}

class LoadNotificationsEvent extends NotificationsEvent {}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  final int notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}
