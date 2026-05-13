import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: selecciono el equipo "Manchester City"
Future<void> seleccionoElEquipo(WidgetTester tester, String teamName) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.seleccionarEquipo(teamName);
}
