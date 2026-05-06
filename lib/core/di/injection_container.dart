import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

import 'service_locator.dart';
export 'service_locator.dart';
import '../storage/secure_storage_service.dart';
import '../theme/bloc/theme_bloc.dart';

// Importaciones de Módulos DI
import 'modules/core_module.dart';
import 'modules/auth_module.dart';
import 'modules/teams_module.dart';
import 'modules/matches_module.dart';
import 'modules/payments_module.dart';
import 'modules/notifications_module.dart';
import 'modules/profile_module.dart';
import 'modules/catalogs_module.dart';
import 'modules/rankings_module.dart';

Future<void> init() async {
  // 1. Inicializar Módulos de cada Feature (Orden de dependencia: Core primero)
  await initCore();
  
  // 2. Especial: Inicialización del Tema (Requiere await para leer de disco)
  await _initTheme();

  // 3. Inicializar el resto de features en paralelo o secuencia
  await initAuth();
  await initTeams();
  await initMatches();
  await initPayments();
  await initNotifications();
  await initProfile();
  await initCatalogs();
  await initRankings();
}

Future<void> _initTheme() async {
  // Cargamos el modo de tema guardado al arrancar
  // Usamos una instancia temporal de storage para la lectura inicial
  final secureStorage = SecureStorageService(const FlutterSecureStorage());
  final isDark = await secureStorage.isDarkMode();
  final initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  sl.registerLazySingleton(() => ThemeBloc(initialThemeMode, sl()));
}
