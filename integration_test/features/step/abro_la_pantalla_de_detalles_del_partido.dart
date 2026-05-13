import 'package:flutter_test/flutter_test.dart';

/// Usage: abro la pantalla de detalles del partido
Future<void> abroLaPantallaDeDetallesDelPartido(WidgetTester tester) async {
  // En el Hub, seleccionamos el primer partido disponible
  final card = find.textContaining('Capitán').first;
  await tester.tap(card);
  await tester.pumpAndSettle();
}
