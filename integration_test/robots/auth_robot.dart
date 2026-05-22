import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchday_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:matchday_app/core/widgets/animated_bouncing_button.dart';

class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  Future<void> ingresarEmail(String email) async {
    print('🚀 [AuthRobot] Intentando ingresar email: $email');
    // 1) Prefer `Key('email')`
    final byKey = find.byKey(const ValueKey('email'));
    if (byKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(byKey);
      await tester.tap(byKey);
      await tester.pump();
      await tester.enterText(byKey, email);
      print('✅ [AuthRobot] Email ingresado por key.');
      await tester.pumpAndSettle();
      return;
    }

    // 2) Fallback: usar el primer campo del formulario como email.
    final anyField = find.byType(TextFormField);
    final anyTextField = find.byType(TextField);
    if (anyField.evaluate().isNotEmpty) {
      final target = anyField.first;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.enterText(target, email);
      print('✅ [AuthRobot] Email ingresado en primer TextFormField.');
      await tester.pumpAndSettle();
      return;
    } else if (anyTextField.evaluate().isNotEmpty) {
      final target = anyTextField.first;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.enterText(target, email);
      print('✅ [AuthRobot] Email ingresado en primer TextField.');
      await tester.pumpAndSettle();
      return;
    }

    print('❌ [AuthRobot] No se encontró ningún campo para el email.');
  }

  Future<void> ingresarPassword(String password) async {
    print('🚀 [AuthRobot] Intentando ingresar contraseña...');
    // 1) Prefer Key
    final byKey = find.byKey(const ValueKey('password'));
    if (byKey.evaluate().isNotEmpty) {
      await tester.ensureVisible(byKey);
      await tester.tap(byKey);
      await tester.pump();
      await tester.enterText(byKey, password);
      print('✅ [AuthRobot] Contraseña ingresada por key.');
      await tester.pumpAndSettle();
      return;
    }

    // 2) Fallback: usar el segundo campo del formulario como contraseña.
    final allFields = find.byType(TextFormField);
    final anyTextField = find.byType(TextField);
    if (allFields.evaluate().length > 1) {
      final target = allFields.at(1);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.enterText(target, password);
      print('✅ [AuthRobot] Contraseña ingresada en segundo TextFormField.');
      await tester.pumpAndSettle();
      return;
    } else if (anyTextField.evaluate().length > 1) {
      final target = anyTextField.at(1);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.enterText(target, password);
      print('✅ [AuthRobot] Contraseña ingresada en segundo TextField.');
      await tester.pumpAndSettle();
      return;
    } else if (anyTextField.evaluate().isNotEmpty) {
      final target = anyTextField.first;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.enterText(target, password);
      print('✅ [AuthRobot] Contraseña ingresada en primer TextField.');
      await tester.pumpAndSettle();
      return;
    }

    print('❌ [AuthRobot] No se encontró ningún campo para la contraseña.');
  }

  Future<void> clickLogin() async {
    print('🚀 [AuthRobot] Intentando pulsar el botón de login...');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // 1) Preferir el botón real del login si existe
    final bouncingBtn = find.byType(AnimatedBouncingButton);
    if (bouncingBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(bouncingBtn.first);
      await tester.tap(bouncingBtn.first, warnIfMissed: false);
      print('✅ [AuthRobot] Click en AnimatedBouncingButton (login).');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      return;
    }

    // 2) Buscar por varias variantes de texto (case-insensitive)
    final possibleTexts = [
      'Iniciar Sesión',
      'INICIAR SESIÓN',
      'Iniciar sesión',
      'Entrar',
      'LOGIN',
    ];
    Finder? loginBtn;
    for (final t in possibleTexts) {
      final f = find.widgetWithText(ElevatedButton, t);
      if (f.evaluate().isNotEmpty) {
        loginBtn = f;
        break;
      }
    }

    // También comprobar Text dentro de GestureDetector/InkWell
    if (loginBtn == null) {
      for (final t in possibleTexts) {
        final f = find.text(t);
        if (f.evaluate().isNotEmpty) {
          loginBtn = f;
          break;
        }
      }
    }

    // Fallback: cualquier ElevatedButton
    if (loginBtn == null && find.byType(ElevatedButton).evaluate().isNotEmpty) {
      loginBtn = find.byType(ElevatedButton).first;
    }

    if (loginBtn != null && loginBtn.evaluate().isNotEmpty) {
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
    final profileIcon = find.byIcon(Icons.person_outline);
    if (profileIcon.evaluate().isNotEmpty) {
      await tester.tap(profileIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Pantalla de perfil abierta');
      return;
    }

    final avatar = find.byType(CircleAvatar);
    if (avatar.evaluate().length == 1) {
      await tester.tap(avatar.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Pantalla de perfil abierta');
    } else if (avatar.evaluate().isNotEmpty) {
      print('⚠️ Se encontró más de un CircleAvatar; usando el primero.');
      await tester.tap(avatar.first);
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
      final loginWelcomeBtnUpper = find.text('INICIAR SESIÓN');
      final loginWelcomeBtnAny = find.textContaining(
        RegExp('iniciar\s+sesión', caseSensitive: false),
      );

      if (welcomeBtn.evaluate().isNotEmpty) {
        print('🖱️ Pulsando ¡Comenzar!...');
        await tester.tap(welcomeBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (loginWelcomeBtn.evaluate().isNotEmpty) {
        print('🖱️ Pulsando Iniciar Sesión (Bienvenida)...');
        await tester.tap(loginWelcomeBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (loginWelcomeBtnUpper.evaluate().isNotEmpty) {
        print('🖱️ Pulsando INICIAR SESIÓN (Bienvenida)...');
        await tester.tap(loginWelcomeBtnUpper.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (loginWelcomeBtnAny.evaluate().isNotEmpty) {
        print('🖱️ Pulsando botón de login detectado por regex...');
        await tester.tap(loginWelcomeBtnAny.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    // 3. Ingresar credenciales
    // Aseguramos que los campos ya cargaron tras la navegación
    if (find.text('Correo Electrónico').evaluate().isEmpty) {
      print('⌛ Esperando un poco más a que aparezcan los campos de texto...');
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // Si la UI muestra explícitamente las etiquetas del formulario, usar la posición
    final hasEmailLabel =
        find
            .textContaining(RegExp('correo', caseSensitive: false))
            .evaluate()
            .isNotEmpty ||
        find
            .textContaining(RegExp('correo electr', caseSensitive: false))
            .evaluate()
            .isNotEmpty ||
        find
            .textContaining(
              RegExp('correo electr[oó]nico', caseSensitive: false),
            )
            .evaluate()
            .isNotEmpty;
    final hasPasswordLabel = find
        .textContaining(RegExp('contrase', caseSensitive: false))
        .evaluate()
        .isNotEmpty;

    if (hasEmailLabel) {
      // Asumir que el primer TextFormField es el email
      final allFields = find.byType(TextFormField);
      if (allFields.evaluate().isNotEmpty) {
        final target = allFields.first;
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump();
        await tester.enterText(target, email);
        print('✅ [AuthRobot] Email ingresado (por etiqueta detectada).');
        await tester.pumpAndSettle();
      }
    } else {
      await ingresarEmail(email);
    }

    if (hasPasswordLabel) {
      final allFields = find.byType(TextFormField);
      if (allFields.evaluate().length > 1) {
        final target = allFields.at(1);
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump();
        await tester.enterText(target, password);
        print('✅ [AuthRobot] Contraseña ingresada (por etiqueta detectada).');
        await tester.pumpAndSettle();
      } else {
        await ingresarPassword(password);
      }
    } else {
      await ingresarPassword(password);
    }

    // Click login
    // Preferir AnimatedBouncingButton si existe
    if (find.byType(AnimatedBouncingButton).evaluate().isNotEmpty) {
      final btn = find.byType(AnimatedBouncingButton).first;
      await tester.ensureVisible(btn);
      await tester.tap(btn, warnIfMissed: false);
      print('✅ [AuthRobot] Click en AnimatedBouncingButton (login).');
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } else {
      await clickLogin();
    }

    // 4. Verificar Home
    await verificarHome();
  }
}
