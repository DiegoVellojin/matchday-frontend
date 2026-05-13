import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Uso: ingreso el correo "test@matchday.com"
Future<void> ingresoElCorreoTestmatchdaycom(WidgetTester tester) async {
  // Si ya estamos en el Hub (vemos 'Equipos'), saltamos este paso
  if (find.text('Equipos').evaluate().isNotEmpty) {
    print('ℹ️ Ya en el Hub, saltando ingreso de correo.');
    return;
  }

  final authRobot = AuthRobot(tester);
  await authRobot.ingresarEmail('test@matchday.com');
}
