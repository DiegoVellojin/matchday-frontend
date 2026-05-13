import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

/// Usage: selecciono la cancha "Estadio Olímpico UCV"
Future<void> seleccionoLaCancha(WidgetTester tester, String fieldName) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.seleccionarCancha('Caracas', fieldName);
}
