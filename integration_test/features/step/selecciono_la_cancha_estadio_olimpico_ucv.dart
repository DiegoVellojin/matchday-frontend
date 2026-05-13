import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

Future<void> seleccionoLaCanchaEstadioOlimpicoUcv(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.seleccionarCancha('Caracas', 'Estadio Olímpico UCV');
}
