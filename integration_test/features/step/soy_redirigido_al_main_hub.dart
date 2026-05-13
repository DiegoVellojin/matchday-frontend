import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Usage: soy redirigido al Main Hub
Future<void> soyRedirigidoAlMainHub(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  await authRobot.verificarHome();
}
