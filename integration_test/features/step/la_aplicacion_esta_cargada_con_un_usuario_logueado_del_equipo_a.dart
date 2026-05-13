import 'package:flutter_test/flutter_test.dart';
import 'estoy_logueado_en_la_aplicacion.dart';

/// Usage: la aplicación está cargada con un usuario logueado del Equipo A
Future<void> laAplicacionEstaCargadaConUnUsuarioLogueadoDelEquipoA(WidgetTester tester) async {
  // Por ahora, usamos el login estándar que ya implementamos
  await estoyLogueadoEnLaAplicacion(tester);
  
  // Podríamos añadir navegación específica aquí si fuera necesario
  await tester.pumpAndSettle();
}
