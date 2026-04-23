import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../infrastructure/datasources/auth_remote_data_source.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF39CEA5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.emoji_events, size: 48, color: Colors.black),
              ),
              const SizedBox(height: 16),
              const Text('MatchDay', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 48),

              // Formulario
              _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', icon: Icons.mail_outline),
              const SizedBox(height: 20),
              // Aquí pasamos el context para que el Textfield sepa cómo navegar
              _buildTextField(label: 'Contraseña', hint: 'Ingresa tu contraseña', icon: Icons.lock_outline, isPassword: true, context: context),
              const SizedBox(height: 24),

              // Botón Principal
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí luego conectaremos el AuthRobot
                    // context.go('/equipos'); // Navegar a Home temporalmente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39CEA5),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              // Divisor
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('O', style: TextStyle(color: const Color(0xFF9CA3AF).withOpacity(0.8))),
                    ),
                    const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                  ],
                ),
              ),

              // Botón de Google
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final authSource = AuthRemoteDataSource();
                    
                    // Mostramos un loader visual rápido (opcional pero recomendado)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo Google...'), duration: Duration(seconds: 1)),
                    );

                    try {
                      final idToken = await authSource.signInWithGoogle();
                      
                      if (idToken != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Login exitoso con Google!'),
                            backgroundColor: Color(0xFF39CEA5),
                          ),
                        );
                        // context.go('/equipos'); // Descomentar cuando tengamos el Hub
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cancelado o error de conexión'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.black),
                  label: const Text('Continuar con Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Link de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? ', style: TextStyle(color: Color(0xFF9CA3AF))),
                  GestureDetector(
                    onTap: () => context.push('/crear-cuenta'), 
                    child: const Text('Regístrate', style: TextStyle(color: Color(0xFF39CEA5), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Componente reutilizable para los TextFields oscuros
  Widget _buildTextField({required String label, required String hint, required IconData icon, bool isPassword = false, BuildContext? context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500)),
            if (isPassword)
              GestureDetector(
                onTap: () {
                  if (context != null) {
                    context.push('/recuperar-contrasena');
                  }
                }, 
                child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF39CEA5), fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF39CEA5)),
            ),
          ),
        ),
      ],
    );
  }
}