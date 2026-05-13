import 'package:flutter_test/flutter_test.dart';
import 'package:matchday_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Usage: la app está en la pantalla de bienvenida
Future<void> laAppEstaEnLaPantallaDeBienvenida(WidgetTester tester) async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Arrancamos la aplicación real
  app.main();
  
  // Esperamos a que la Splash Screen termine (tiene unos 2.2s de delay real)
  bool foundLogin = false;
  bool alreadyLoggedIn = false;
  
  for (int i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    
    // Si vemos 'Equipos', es que ya estamos dentro (login persistente)
    if (find.text('Equipos').evaluate().isNotEmpty) {
      alreadyLoggedIn = true;
      break;
    }
    
    // Si vemos 'Iniciar Sesión', es que hay que loguearse
    if (find.text('Iniciar Sesión').evaluate().isNotEmpty) {
      foundLogin = true;
      break;
    }
  }
  
  if (alreadyLoggedIn) {
    print('ℹ️ Usuario ya logueado, saltando pantalla de bienvenida.');
    return;
  }

  if (!foundLogin) {
    fail('No se encontró ni el Hub ni el botón "Iniciar Sesión" tras esperar 6 segundos.');
  }

  // Estamos en la WelcomePage, pulsamos para ir al LoginPage
  await tester.tap(find.text('Iniciar Sesión').first);
  await tester.pumpAndSettle();
}
