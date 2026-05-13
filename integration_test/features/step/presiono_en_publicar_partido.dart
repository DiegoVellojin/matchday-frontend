import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

/// Usage: presiono en "Publicar Partido"
Future<void> presionoEnPublicarPartido(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.publicar();
}
