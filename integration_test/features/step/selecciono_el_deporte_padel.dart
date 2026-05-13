import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';
import '../../robots/matches_robot.dart';

Future<void> seleccionoElDeportePadel(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  final matchesRobot = MatchesRobot(tester, authRobot: authRobot);
  await matchesRobot.seleccionarDeporte('Pádel');
}
