import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

/// Usage: selecciono el deporte "Pádel"
Future<void> seleccionoElDeporte(WidgetTester tester, String sportName) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.seleccionarDeporte(sportName);
}
