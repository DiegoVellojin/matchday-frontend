import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: navego a la sección de "Equipos"
Future<void> navegoALaSeccionDeEquipos(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.navegarAEquipos();
}
