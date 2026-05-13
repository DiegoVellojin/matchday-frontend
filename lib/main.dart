import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';
import 'features/config/presentation/bloc/config_bloc.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 1. Aseguramos que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializamos el formateo de fechas en español
  await initializeDateFormatting('es_VE', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicializamos GetIt ANTES de correr la app
  await di.init();

  runApp(const MatchDayApp());
}

class MatchDayApp extends StatelessWidget {
  const MatchDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la app en los BLoCs globales (Tema, Perfil, Notif, Auth, Config)
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeBloc>()),
        BlocProvider(
          create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent()),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<NotificationsBloc>()..add(LoadNotificationsEvent()),
        ),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(
          create: (_) => di.sl<ConfigBloc>()..add(FetchRatesEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, currentThemeMode) {
          return MaterialApp.router(
            title: 'MatchDay',
            debugShowCheckedModeBanner: false,
            themeMode: currentThemeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
            locale: const Locale('es', 'ES'),
          );
        },
      ),
    );
  }
}
