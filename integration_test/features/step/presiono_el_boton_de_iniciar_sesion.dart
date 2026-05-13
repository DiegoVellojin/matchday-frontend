import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Usage: presiono el botón de iniciar sesión
Future<void> presionoElBotonDeIniciarSesion(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  await authRobot.clickLogin();
}
