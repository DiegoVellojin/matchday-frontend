import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Eventos
abstract class ThemeEvent {}
class ToggleThemeEvent extends ThemeEvent {}

// El Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  // Arrancamos en Dark Mode por defecto
  ThemeBloc() : super(ThemeMode.dark) {
    on<ToggleThemeEvent>((event, emit) {
      // Si está oscuro, pásalo a claro. Si está claro, pásalo a oscuro.
      emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    });
  }
}