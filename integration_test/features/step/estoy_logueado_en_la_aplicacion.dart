import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: estoy logueado en la aplicación
Future<void> estoyLogueadoEnLaAplicacion(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  await teamsRobot.asegurarSesion(comoCapitan: false);
}
