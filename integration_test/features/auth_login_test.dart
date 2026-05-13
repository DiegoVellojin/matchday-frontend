// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/la_app_esta_en_la_pantalla_de_bienvenida.dart';
import './step/ingreso_el_correo_vellojindiego7gmailcom.dart';
import './step/ingreso_la_contrasena_password123.dart';
import './step/presiono_el_boton_de_iniciar_sesion.dart';
import './step/soy_redirigido_al_main_hub.dart';
import './step/veo_mi_nombre_test_user_en_el_perfil.dart';

void main() {
  group('''Login de Usuario''', () {
    testWidgets('''Login exitoso con credenciales correctas''', (tester) async {
      await laAppEstaEnLaPantallaDeBienvenida(tester);
      await ingresoElCorreoVellojindiego7gmailcom(tester, 'vellojindiego7@gmail.com');
      await ingresoLaContrasenaPassword123(tester, 'Password123');
      await presionoElBotonDeIniciarSesion(tester);
      await soyRedirigidoAlMainHub(tester);
      await veoMiNombreTestUserEnElPerfil(tester);
    });
  });
}
