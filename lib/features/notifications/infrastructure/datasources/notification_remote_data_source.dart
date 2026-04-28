import '../../../../core/network/network_robot.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final NetworkRobot networkRobot;

  NotificationRemoteDataSource({required this.networkRobot});

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await networkRobot.get('/notifications/');
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar las notificaciones');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await networkRobot.put('/notifications/$notificationId/read');
    } catch (e) {
      throw Exception('Error al marcar la notificación como leída');
    }
  }
}
