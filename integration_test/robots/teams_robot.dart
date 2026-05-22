import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'auth_robot.dart';

class TeamsRobot {
  final WidgetTester tester;
  final AuthRobot authRobot; // Inyección de dependencia explícita

  TeamsRobot(this.tester, {required this.authRobot});

  /// Implementación del paso: "Given estoy logueado como capitán / en la aplicación"
  Future<void> asegurarSesion({bool comoCapitan = false}) async {
    // Usamos el correo del usuario para todos los tests por consistencia
    const email = 'vellojindiego7@gmail.com';
    await authRobot.loginCompleto(email: email, password: 'Password123');
  }

  Future<void> navegarAEquipos() async {
    print('📍 Navegando a la sección "Equipos" (Bottom Nav)...');
    final equiposText = find.text('Equipos').last;
    await tester.ensureVisible(equiposText);
    await tester.tap(equiposText);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> abrirFormularioCreacion() async {
    print('🖱️ Pulsando botón "Crear Equipo"...');
    final crearBtn = find.textContaining(
      RegExp(r'crear equipo', caseSensitive: false),
    );
    final target = crearBtn.evaluate().isNotEmpty
        ? crearBtn
        : find.byIcon(Icons.add);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> ingresarNombreEquipo(String nombre) async {
    print('✏️ Ingresando nombre del equipo: "$nombre"...');
    await _esperarCarga();
    final nameField = find.byType(TextFormField).first;
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, nombre);
    await tester.pumpAndSettle();
  }

  Future<void> crearEquipo() async {
    print('🚀 Pulsando "CREAR EQUIPO"...');
    final exactButton = find.widgetWithText(ElevatedButton, 'CREAR EQUIPO');
    final genericButton = find.textContaining(
      RegExp(r'^crear equipo$', caseSensitive: false),
    );
    final target = exactButton.evaluate().isNotEmpty
        ? exactButton.first
        : genericButton.first;

    await tester.ensureVisible(target);
    await tester.tap(target, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
  }

  Future<void> verificarEquipoEnMisEquipos(String nombreEquipo) async {
    print('📍 Navegando a "Mis Equipos"...');
    final tabText = find.text('Mis Equipos');
    if (tabText.evaluate().isNotEmpty) {
      await tester.ensureVisible(tabText.last);
      await tester.tapAt(tester.getCenter(tabText.last));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    final equipoEncontrado = find
        .textContaining(nombreEquipo)
        .evaluate()
        .isNotEmpty;
    expect(
      equipoEncontrado,
      isTrue,
      reason: 'El equipo $nombreEquipo no está listado.',
    );
  }

  Future<void> seleccionarEquipo(String nombre) async {
    print('🖱️ Seleccionando equipo "$nombre"...');
    await _esperarCarga();
    final target = find.textContaining(RegExp(nombre, caseSensitive: false));
    expect(
      target,
      findsWidgets,
      reason: 'No se encontró el equipo "$nombre" en la grilla de equipos.',
    );
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> solicitarUnirse() async {
    print('🖱️ Pulsando botón "Solicitar Unirse"...');
    Finder target = find.textContaining(
      RegExp(r'^UNIRSE$', caseSensitive: false),
    );
    if (target.evaluate().isEmpty) {
      target = find.textContaining(
        RegExp(r'SOLICITAR UNIRSE AL EQUIPO', caseSensitive: false),
      );
    }
    expect(
      target,
      findsWidgets,
      reason:
          'No se encontró un botón de acción para solicitar unirse al equipo.',
    );
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> verificarMensajeConfirmacion(String mensaje) async {
    final expected = find.textContaining(RegExp(mensaje, caseSensitive: false));
    final successFallback = find.textContaining(
      RegExp(r'solicitud enviada|con éxito|exito', caseSensitive: false),
    );
    final idempotentFallback = find.textContaining(
      RegExp(
        r'ya (envi|solicit)|solicitud (ya )?exist|pendiente',
        caseSensitive: false,
      ),
    );

    bool found = false;
    for (int i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      found =
          expected.evaluate().isNotEmpty ||
          successFallback.evaluate().isNotEmpty ||
          idempotentFallback.evaluate().isNotEmpty;
      if (found) break;
    }

    expect(
      found,
      isTrue,
      reason: 'No se encontró el mensaje de confirmación "$mensaje".',
    );
  }

  Future<void> verificarListaEquipos() async {
    expect(find.byType(GridView), findsOneWidget);
  }

  Future<void> _esperarCarga() async {
    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }
}
