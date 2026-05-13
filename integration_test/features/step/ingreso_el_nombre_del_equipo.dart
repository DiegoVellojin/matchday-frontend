import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: ingreso el nombre del equipo "Test FC E2E"
Future<void> ingresoElNombreDelEquipo(WidgetTester tester, String name) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.ingresarNombreEquipo(name);
}
