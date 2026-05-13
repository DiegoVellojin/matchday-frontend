import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Usage: ingreso la contraseña "Password123"
Future<void> ingresoLaContrasenaPassword123(WidgetTester tester, String password) async {
  final authRobot = AuthRobot(tester);
  await authRobot.ingresarPassword(password);
}
