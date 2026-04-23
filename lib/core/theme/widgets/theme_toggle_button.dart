import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode, 
            color: Theme.of(context).colorScheme.onSurface, // Se adapta al fondo
          ),
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },
        );
      },
    );
  }
}