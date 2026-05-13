import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchday_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  Future<void> ingresarEmail(String email) async {
    print('🚀 [AuthRobot] Intentando ingresar email: $email');
    final fieldFinder = find.widgetWithText(
      TextFormField,
      'Correo Electrónico',
    );
    final allFields = find.byType(TextFormField);

    Finder target;
    if (fieldFinder.evaluate().isNotEmpty) {
      target = fieldFinder;
    } else if (allFields.evaluate().isNotEmpty) {
      target = allFields.first;
    } else {
      print('❌ [AuthRobot] No se encontró ningún campo para el email.');
      return;
    }

    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.enterText(target, email);
    print('✅ [AuthRobot] Email ingresado.');
    await tester.pumpAndSettle();
  }

  Future<void> ingresarPassword(String password) async {
    print('🚀 [AuthRobot] Intentando ingresar contraseña...');
    final fieldFinder = find.widgetWithText(TextFormField, 'Contraseña');
    final allFields = find.byType(TextFormField);

    Finder target;
    if (fieldFinder.evaluate().isNotEmpty) {
      target = fieldFinder;
    } else if (allFields.evaluate().length > 1) {
      target = allFields.at(1);
    } else if (allFields.evaluate().isNotEmpty) {
      target = allFields.first;
    } else {
      print('❌ [AuthRobot] No se encontró ningún campo para la contraseña.');
      return;
    }

    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.enterText(target, password);
    print('✅ [AuthRobot] Contraseña ingresada.');
    await tester.pumpAndSettle();
  }

  Future<void> clickLogin() async {
    print('🚀 [AuthRobot] Intentando pulsar el botón de login...');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final loginBtn = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
    if (loginBtn.evaluate().isNotEmpty) {
      final target = loginBtn.last;
      await tester.ensureVisible(target);
      await tester.tap(target, warnIfMissed: false);
      print('✅ [AuthRobot] Click en Login realizado.');
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } else {
      print('❌ [AuthRobot] No se encontró el botón de Iniciar Sesión.');
    }
  }

  Future<void> verificarHome() async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final estaEnHome = find.text('Equipos').evaluate().isNotEmpty;
    if (!estaEnHome) {
      print('📋 Diagnóstico - Elementos visibles:');
      for (final element in find.byType(Text).evaluate()) {
        final t = element.widget as Text;
        if (t.data != null) print('  - "${t.data}"');
      }
      fail('❌ El login falló o no llegó al Home.');
    }
    expect(estaEnHome, isTrue);
  }

  Future<void> abrirPerfil() async {
    print('🖱️ Abriendo perfil del usuario...');
    final avatar = find.byType(CircleAvatar);
    if (avatar.evaluate().isNotEmpty) {
      await tester.tap(avatar);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Pantalla de perfil abierta');
    } else {
      print('⚠️ No se encontró el avatar de perfil.');
    }
  }

  /// Flujo completo de login centralizado (DRY)
  Future<void> loginCompleto({
    required String email,
    required String password,
  }) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    // FORZAMOS SIEMPRE EL REINICIO DE LA APP PARA AISLAR LOS TESTS
    print(
      '🚀 Inicializando/Reiniciando aplicación MatchDay de forma limpia...',
    );
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    print('⏳ Esperando estabilización de la UI...');
    bool appLista = false;
    for (int i = 0; i < 30; i++) {
      // Búsqueda amplia para ver si hay algo en pantalla
      final bienvenidos = find.text('¡Comenzar!').evaluate().isNotEmpty;
      final login = find.text('Correo Electrónico').evaluate().isNotEmpty;
      final hub = find.text('Equipos').evaluate().isNotEmpty;
      final scaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      final appName = find.text('MatchDay').evaluate().isNotEmpty;

      if (bienvenidos || login || hub || scaffold || appName) {
        appLista = true;
        print('✅ UI Detectada (i=$i)');
        break;
      }
      await tester.pump(const Duration(seconds: 1));
    }

    if (!appLista) {
      print(
        '⚠️ La app parece no haber cargado tras 30 segundos. Intentando forzar un pumpAndSettle...',
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 1. ¿Ya estamos logueados?
    if (find.text('Equipos').evaluate().isNotEmpty) {
      print(
        'ℹ️ Usuario ya logueado en esta sesión persistente, saltando login.',
      );
      return;
    }

    print('🔐 Iniciando flujo centralizado de login para: $email');

    // 2. Navegar desde la Pantalla de Bienvenida si es necesario
    final hayCamposLogin = find
        .text('Correo Electrónico')
        .evaluate()
        .isNotEmpty;
    if (!hayCamposLogin) {
      print(
        '👋 Parece que estamos en la Bienvenida. Buscando botón para entrar...',
      );
      final welcomeBtn = find.text('¡Comenzar!');
      final loginWelcomeBtn = find.text('Iniciar Sesión');

      if (welcomeBtn.evaluate().isNotEmpty) {
        print('🖱️ Pulsando ¡Comenzar!...');
        await tester.tap(welcomeBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (loginWelcomeBtn.evaluate().isNotEmpty) {
        print('🖱️ Pulsando Iniciar Sesión (Bienvenida)...');
        await tester.tap(loginWelcomeBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    // 3. Ingresar credenciales
    // Aseguramos que los campos ya cargaron tras la navegación
    if (find.text('Correo Electrónico').evaluate().isEmpty) {
      print('⌛ Esperando un poco más a que aparezcan los campos de texto...');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    await ingresarEmail(email);
    await ingresarPassword(password);
    await clickLogin();

    // 4. Verificar Home
    await verificarHome();
  }
}
