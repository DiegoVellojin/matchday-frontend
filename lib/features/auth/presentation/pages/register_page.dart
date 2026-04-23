import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón de retroceso
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 16),
              
              // Títulos
              const Text('Comenzar', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text(
                'Únete a la comunidad o continúa instantáneamente con Google.',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 32),

              // Botón de Google
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.black),
                  label: const Text('Continuar con Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                      child: Text('O con Email', style: TextStyle(color: const Color(0xFF9CA3AF).withOpacity(0.8))),
                    ),
                    const Expanded(child: Divider(color: Color(0xFF2A2A2A))),
                  ],
                ),
              ),

              // Campos del Formulario
              _buildTextField(label: 'Nombre Completo', hint: 'Ingresa tu nombre completo', icon: Icons.person_outline),
              const SizedBox(height: 20),
              _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', icon: Icons.mail_outline),
              const SizedBox(height: 20),
              _buildTextField(label: 'Contraseña', hint: 'Crea una contraseña', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 20),
              _buildTextField(label: 'Confirmar Contraseña', hint: 'Confirma tu contraseña', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 24),

              // Checkbox de Términos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _acceptedTerms ? const Color(0xFF39CEA5) : Colors.transparent,
                        border: Border.all(color: _acceptedTerms ? const Color(0xFF39CEA5) : const Color(0xFF2A2A2A), width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _acceptedTerms ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Acepto los ',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Términos y Condiciones',
                            style: TextStyle(color: Color(0xFF39CEA5), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Crear Cuenta
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {}, // context.go('/equipos')
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39CEA5),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Crear Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 24),
              // Link de Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? ', style: TextStyle(color: Color(0xFF9CA3AF))),
                  GestureDetector(
                    onTap: () => context.push('/iniciar-sesion'),
                    child: const Text('Inicia Sesión', style: TextStyle(color: Color(0xFF39CEA5), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500)),
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
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF39CEA5))),
          ),
        ),
      ],
    );
  }
}