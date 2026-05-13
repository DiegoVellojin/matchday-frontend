// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/estoy_logueado_en_la_aplicacion.dart';
import './step/navego_a_la_seccion_de_equipos.dart';
import './step/veo_una_lista_de_equipos_disponibles.dart';
import './step/selecciono_el_equipo.dart';
import './step/presiono_en_solicitar_unirse.dart';
import './step/veo_un_mensaje_de_confirmacion_solicitud_enviada_con_exito.dart';

void main() {
  group('''Descubrimiento de Equipos''', () {
    testWidgets('''Usuario busca y solicita unirse a un equipo''',
        (tester) async {
      await estoyLogueadoEnLaAplicacion(tester);
      await navegoALaSeccionDeEquipos(tester);
      await veoUnaListaDeEquiposDisponibles(tester);
      await seleccionoElEquipo(tester, 'Manchester City');
      await presionoEnSolicitarUnirse(tester);
      await veoUnMensajeDeConfirmacionSolicitudEnviadaConExito(tester);
    });
  });
}
