import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/secure_storage_service.dart';

// Eventos
abstract class ThemeEvent {}
class ToggleThemeEvent extends ThemeEvent {}

// El Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  final SecureStorageService secureStorageService;

  ThemeBloc(ThemeMode initialMode, this.secureStorageService) : super(initialMode) {
    on<ToggleThemeEvent>((event, emit) async {
      final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      emit(newMode);
      // Guardar el nuevo estado en persistencia
      await secureStorageService.saveThemeMode(newMode == ThemeMode.dark);
    });
  }
}