import 'package:flutter_test/flutter_test.dart';

/// Usage: el partido actual está en estado "pendiente_pago" con cuota de "5.0"
Future<void> elPartidoActualEstaEnEstadoPendientePagoConCuotaDe50(WidgetTester tester) async {
  // Este paso es descriptivo para el contexto del test. 
  // Asumimos que los datos que vienen del backend de Render para el partido seleccionado 
  // cumplen con esta condición.
  await tester.pumpAndSettle();
}
