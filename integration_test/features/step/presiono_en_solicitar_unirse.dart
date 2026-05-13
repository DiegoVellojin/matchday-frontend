import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: presiono en "Solicitar Unirse"
Future<void> presionoEnSolicitarUnirse(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.solicitarUnirse();
}
