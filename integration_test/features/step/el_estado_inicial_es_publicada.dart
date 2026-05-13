import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

Future<void> elEstadoInicialEsPublicada(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.verificarEstado('PUBLICADA');
}
