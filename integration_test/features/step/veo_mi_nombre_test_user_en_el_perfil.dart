import 'package:flutter_test/flutter_test.dart';
import '../../robots/auth_robot.dart';

/// Usage: veo mi nombre "Diego Vellojin" en el perfil
Future<void> veoMiNombreTestUserEnElPerfil(WidgetTester tester) async {
  final authRobot = AuthRobot(tester);
  
  // 1. Abrir la pantalla de perfil primero
  await authRobot.abrirPerfil();

  // 2. Verificar el nombre del usuario Diego Vellojin en la pantalla
  print('🧐 Verificando nombre en el perfil...');
  expect(find.textContaining('Diego'), findsWidgets);
  expect(find.textContaining('Vellojin'), findsWidgets);
  print('✅ Nombre verificado correctamente');
}
