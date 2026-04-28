class NotificationEntity {
  final int id;
  final int userId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? type;
  final int? referenceId;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.referenceId,
  });
}
