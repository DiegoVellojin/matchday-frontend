import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

/// Usage: el partido aparece en mi lista de partidos activos
Future<void> elPartidoApareceEnMiListaDePartidosActivos(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.verificarPartidoEnLista();
}
