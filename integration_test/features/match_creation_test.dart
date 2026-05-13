// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/estoy_logueado_como_capitan_de_un_equipo.dart';
import './step/abro_el_formulario_de_creacion_de_partido.dart';
import './step/selecciono_el_deporte_padel.dart';
import './step/selecciono_la_cancha_estadio_olimpico_ucv.dart';
import './step/presiono_en_publicar_partido.dart';
import './step/el_partido_aparece_en_mi_lista_de_partidos_activos.dart';

void main() {
  group('''Creación de Partido por Capitán''', () {
    testWidgets('''Capitán publica un partido exitosamente''', (tester) async {
      await estoyLogueadoComoCapitanDeUnEquipo(tester);
      await abroElFormularioDeCreacionDePartido(tester);
      await seleccionoElDeportePadel(tester);
      await seleccionoLaCanchaEstadioOlimpicoUcv(tester);
      await presionoEnPublicarPartido(tester);
      await elPartidoApareceEnMiListaDePartidosActivos(tester);
    });
  });
}
