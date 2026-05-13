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
    final crearBtn = find.textContaining('Crear Equipo');
    final target = crearBtn.evaluate().isNotEmpty
        ? crearBtn
        : find.byIcon(Icons.add);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle(const Duration(seconds: 3));
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
    print('🚀 Pulsando "Crear Equipo & Invitar Amigos"...');
    final scrollable = find.byType(SingleChildScrollView);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    final btn = find.textContaining('Crear Equipo').last;
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle(const Duration(seconds: 5));
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
    final equipo = find.textContaining(nombre);
    final target = equipo.evaluate().isNotEmpty
        ? equipo.first
        : find.byType(GestureDetector).first;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> solicitarUnirse() async {
    print('🖱️ Pulsando botón "Solicitar Unirse"...');
    final btn = find.textContaining(
      RegExp(r'(Unirse|Solicitar)', caseSensitive: false),
    );
    final target = btn.evaluate().isNotEmpty
        ? btn.first
        : find.byType(ElevatedButton).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> verificarMensajeConfirmacion(String mensaje) async {
    expect(find.textContaining(mensaje), findsWidgets);
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
