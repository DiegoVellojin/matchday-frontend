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
    print('📍 Navegando al tab de Partidos antes de abrir el formulario...');
    final navItem = find.text('Partidos').first;
    await tester.ensureVisible(navItem);
    await tester.tap(navItem);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final organizeBtn = find.text('ORGANIZAR');
    if (organizeBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(organizeBtn);
      await tester.tap(organizeBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      return;
    }

    final fab = find.byType(FloatingActionButton);
    await tester.ensureVisible(fab.first);
    await tester.tap(fab.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> seleccionarDeporte(String deporte) async {
    await _esperarCarga();
    final selector = _findInteractableDropdown(
      fallbackReason:
          'No se encontró un selector de deporte interactivo en el formulario.',
    );
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    final opcion = _findTextIgnoringAccents(deporte).first;
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
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(
        scrollable.first,
        const Offset(0, -50),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    final regionSelector = _findDropdownByHintOrNullValueFallback(
      hintText: 'selecciona una ciudad',
      fallbackReason:
          'No se encontró el selector de ciudad por hint ni por estado inicial sin selección.',
    );

    print('ℹ️ Abriendo selector de Ciudad ($ciudad)...');
    await tester.ensureVisible(regionSelector);
    await tester.tap(regionSelector);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final regionFinder = _findTextIgnoringAccents(ciudad);
    final capitalFinder = (ciudad.toLowerCase() == 'caracas')
        ? _findTextIgnoringAccents('Caracas')
        : null;

    Finder targetRegion;
    if (regionFinder.evaluate().isNotEmpty) {
      targetRegion = regionFinder.first;
    } else if (capitalFinder != null && capitalFinder.evaluate().isNotEmpty) {
      targetRegion = capitalFinder.first;
    } else {
      print('⚠️ $ciudad no visible, forzando scroll en el menú de BD...');
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -300),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      targetRegion = regionFinder.evaluate().isNotEmpty
          ? regionFinder.first
          : find
                .byWidgetPredicate(
                  (w) => w.runtimeType.toString().contains('DropdownMenuItem'),
                )
                .first;
    }

    await tester.ensureVisible(targetRegion);
    await tester.tap(targetRegion, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('⌛ Esperando carga de canchas de Render...');
    await _esperarCarga();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('🏟️ Abriendo selector de canchas...');
    final selectorCancha = _findDropdownByHintOrNullValueFallback(
      hintText: 'selecciona una cancha',
      fallbackReason:
          'No se encontró el selector de cancha por hint ni por estado inicial sin selección.',
    );
    await tester.ensureVisible(selectorCancha);
    await tester.tap(selectorCancha, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final itemsCancha = find.byWidgetPredicate(
      (w) => w.runtimeType.toString().contains('DropdownMenuItem'),
    );
    final canchaFinder = _findTextIgnoringAccents(cancha);
    Finder targetCancha = canchaFinder.evaluate().isNotEmpty
        ? canchaFinder.first
        : itemsCancha.first;

    await tester.ensureVisible(targetCancha);
    await tester.tap(targetCancha);
    await tester.pumpAndSettle();
  }

  Finder _findDropdownByHintOrNullValueFallback({
    required String hintText,
    required String fallbackReason,
  }) {
    final byHint = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButton<int> &&
          widget.hint is Text &&
          ((widget.hint as Text).data?.toLowerCase().contains(
                hintText.toLowerCase(),
              ) ??
              false),
    );
    if (byHint.evaluate().isNotEmpty) return byHint.first;

    final nullValueDropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButton<int> &&
          widget.value == null &&
          widget.onChanged != null &&
          widget.items != null &&
          widget.items!.isNotEmpty,
    );
    expect(nullValueDropdown, findsWidgets, reason: fallbackReason);
    return nullValueDropdown.first;
  }

  Finder _findInteractableDropdown({required String fallbackReason}) {
    final interactable = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButton<int> &&
          widget.onChanged != null &&
          widget.items != null &&
          widget.items!.isNotEmpty,
    );
    expect(interactable, findsWidgets, reason: fallbackReason);
    return interactable.first;
  }

  Finder _findTextIgnoringAccents(String text) {
    final normalizedNeedle = _normalizeText(text);
    return find.byWidgetPredicate((widget) {
      if (widget is! Text) return false;
      final data = widget.data;
      if (data == null || data.trim().isEmpty) return false;
      return _normalizeText(data).contains(normalizedNeedle);
    });
  }

  String _normalizeText(String input) {
    var out = input.toLowerCase();
    out = out
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ñ', 'n');
    return out;
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
    expect(
      finder,
      findsWidgets,
      reason: 'No se encontró el estado $estado en pantalla.',
    );
  }
}
