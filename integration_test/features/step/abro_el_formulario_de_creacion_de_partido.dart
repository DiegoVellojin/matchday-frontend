import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

/// Usage: abro el formulario de creación de partido
Future<void> abroElFormularioDeCreacionDePartido(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.abrirFormularioCreacion();
}
