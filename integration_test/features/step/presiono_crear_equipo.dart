import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: presiono crear equipo
Future<void> presionoCrearEquipo(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.crearEquipo();
}
