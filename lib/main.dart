import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MatchDayApp());
}

class MatchDayApp extends StatelessWidget {
  const MatchDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchDay',
      debugShowCheckedModeBanner: false, // Quita la etiqueta fea de "DEBUG"
      themeMode: ThemeMode.dark, // Forzamos el Dark Mode que diseñaste
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark slate
        primaryColor: const Color(0xFF39CEA5), // Tu verde neón
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF39CEA5),
          secondary: Color(0xFF39CEA5),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const PlaceholderScreen(), // Pantalla temporal
    );
  }
}

// Un widget temporal mientras armamos las pantallas reales
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MatchDay', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '¡El lienzo está listo!',
          style: TextStyle(fontSize: 20, color: Color(0xFF39CEA5)),
        ),
      ),
    );
  }
}