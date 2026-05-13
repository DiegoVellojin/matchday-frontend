import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/teams_robot.dart';

/// Usage: el equipo aparece en mi lista de "Mis Equipos"
Future<void> elEquipoApareceEnMisEquipos(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final teamsRobot = TeamsRobot(tester, authRobot: authRobot);
  // Usamos el nombre base que se usa en los features
  await teamsRobot.verificarEquipoEnMisEquipos('Test FC E2E');
}
