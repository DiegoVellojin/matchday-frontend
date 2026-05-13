import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.message,
    required super.isRead,
    required super.createdAt,
    super.type,
    super.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id_notificacion'] as int,
      userId: json['fk_id_usuario'] as int,
      message: json['mensaje'] as String,
      isRead: json['leida'] as bool,
      createdAt: DateTime.parse(json['fecha_creacion'].toString().endsWith('Z') 
          ? json['fecha_creacion'] as String 
          : '${json['fecha_creacion']}Z'),
      type: json['tipo'] as String?,
      referenceId: json['referencia_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notificacion': id,
      'fk_id_usuario': userId,
      'mensaje': message,
      'leida': isRead,
      'fecha_creacion': createdAt.toIso8601String(),
      'tipo': type,
      'referencia_id': referenceId,
    };
  }
}
