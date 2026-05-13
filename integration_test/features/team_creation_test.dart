// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/estoy_logueado_como_capitan_de_un_equipo.dart';
import './step/navego_a_la_seccion_de_equipos.dart';
import './step/abro_el_formulario_de_creacion_de_equipo.dart';
import './step/ingreso_el_nombre_del_equipo.dart';
import './step/presiono_crear_equipo.dart';
import './step/el_equipo_aparece_en_mis_equipos.dart';

void main() {
  group('''Creación de Equipo''', () {
    testWidgets('''Usuario crea un equipo exitosamente''', (tester) async {
      await estoyLogueadoComoCapitanDeUnEquipo(tester);
      await navegoALaSeccionDeEquipos(tester);
      await abroElFormularioDeCreacionDeEquipo(tester);
      await ingresoElNombreDelEquipo(tester, 'Test FC E2E');
      await presionoCrearEquipo(tester);
      await elEquipoApareceEnMisEquipos(tester);
    });
  });
}
