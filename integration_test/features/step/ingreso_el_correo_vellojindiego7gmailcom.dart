import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Usage: ingreso el correo "vellojindiego7@gmail.com"
Future<void> ingresoElCorreoVellojindiego7gmailcom(WidgetTester tester, String email) async {
  final authRobot = AuthRobot(tester);
  await authRobot.ingresarEmail(email);
}
