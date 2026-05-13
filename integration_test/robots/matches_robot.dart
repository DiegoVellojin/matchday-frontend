import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'auth_robot.dart';

class MatchesRobot {
  final WidgetTester tester;
  final AuthRobot authRobot; // Inyección de dependencia explícita

  MatchesRobot(this.tester, {required this.authRobot});

  /// Asegura la sesión antes de comenzar cualquier flujo de este dominio
  Future<void> asegurarSesionCapitan() async {
    await authRobot.loginCompleto(
      email: 'vellojindiego7@gmail.com',
      password: 'Password123',
    );
  }

  Future<void> abrirFormularioCreacion() async {
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isEmpty) {
      final navItem = find.text('Partidos').last;
      await tester.ensureVisible(navItem);
      await tester.tap(navItem);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }

  Future<void> seleccionarDeporte(String deporte) async {
    await _esperarCarga();
    final selector = find.byType(DropdownButton<int>).at(0);
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    final opcion = find.textContaining(deporte).last;
    await tester.ensureVisible(opcion);
    await tester.tap(opcion, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> _esperarCarga() async {
    for (int i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      final loading = find.byType(LinearProgressIndicator).evaluate();
      final skeleton = find.text('Cargando').evaluate();
      if (loading.isEmpty && skeleton.isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<void> seleccionarCancha(String ciudad, String cancha) async {
    print('🔄 Micro-scroll de refresco...');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -50));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final regionSelector = find.byType(DropdownButton<int>).at(2);
    print('ℹ️ Abriendo selector de Ciudad ($ciudad)...');
    await tester.ensureVisible(regionSelector);
    await tester.tap(regionSelector);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final regionFinder = find.textContaining(
      RegExp(ciudad, caseSensitive: false),
    );
    final capitalFinder = (ciudad.toLowerCase() == 'caracas')
        ? find.textContaining(RegExp(r'Caracas', caseSensitive: false))
        : null;

    Finder targetRegion;
    if (regionFinder.evaluate().isNotEmpty) {
      targetRegion = regionFinder.last;
    } else if (capitalFinder != null && capitalFinder.evaluate().isNotEmpty) {
      targetRegion = capitalFinder.last;
    } else {
      print('⚠️ $ciudad no visible, forzando scroll en el menú de BD...');
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -300));
      await tester.pumpAndSettle();
      targetRegion = regionFinder.evaluate().isNotEmpty
          ? regionFinder.last
          : find
                .byWidgetPredicate(
                  (w) => w.runtimeType.toString().contains('DropdownMenuItem'),
                )
                .last;
    }

    await tester.ensureVisible(targetRegion);
    await tester.tap(targetRegion, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('⌛ Esperando carga de canchas de Render...');
    await _esperarCarga();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('🏟️ Abriendo selector de canchas...');
    final selectorCancha = find.byType(DropdownButton<int>).at(3);
    await tester.ensureVisible(selectorCancha);
    await tester.tap(selectorCancha, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final itemsCancha = find.byWidgetPredicate(
      (w) => w.runtimeType.toString().contains('DropdownMenuItem'),
    );
    final canchaFinder = find.textContaining(cancha);
    Finder targetCancha = canchaFinder.evaluate().isNotEmpty
        ? canchaFinder.last
        : itemsCancha.first;

    await tester.ensureVisible(targetCancha);
    await tester.tap(targetCancha);
    await tester.pumpAndSettle();
  }

  Future<void> publicar() async {
    final btn = find.text('Buscar o Crear Partido');
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final similarMatchesSheet = find.text('Partidos Similares Encontrados');
    if (similarMatchesSheet.evaluate().isNotEmpty) {
      print(
        '⚠️ Interceptando bottom sheet defensivo. Pulsando "Ignorar y crear mi partido"...',
      );
      final ignoreBtn = find.text('Ignorar y crear mi partido');
      await tester.ensureVisible(ignoreBtn);
      await tester.tap(ignoreBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  Future<void> verificarPartidoEnLista() async {
    print('📍 Navegando a la sección "Partidos" (Bottom Nav)...');
    final tabNav = find.text('Partidos').last;
    await tester.ensureVisible(tabNav);
    await tester.tap(tabNav);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    print('🖱️ Pulsando en el tab "Mis Partidos"...');
    final tabText = find.text('Mis Partidos');
    if (tabText.evaluate().isNotEmpty) {
      await tester.ensureVisible(tabText.last);
      await tester.tapAt(tester.getCenter(tabText.last));
      await tester.pumpAndSettle(const Duration(seconds: 4));
    }

    final validado = find
        .textContaining(RegExp(r'(p[aá]del|UCV)', caseSensitive: false))
        .evaluate()
        .isNotEmpty;
    expect(
      validado,
      isTrue,
      reason: 'No se trazó el partido activo en el viewport.',
    );
  }

  Future<void> verificarEstado(String estado) async {
    print('🧐 Verificando que el estado sea "$estado"...');
    await _esperarCarga();
    final finder = find.textContaining(RegExp(estado, caseSensitive: false));
    expect(finder, findsWidgets, reason: 'No se encontró el estado $estado en pantalla.');
  }
}
