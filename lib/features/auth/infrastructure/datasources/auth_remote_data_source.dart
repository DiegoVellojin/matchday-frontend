import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  // 1. Ahora usamos la instancia Singleton global
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // 2. Nuevo paso obligatorio: Inicializar el plugin
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  /// Abre el modal nativo de Google y retorna el idToken si el usuario acepta.
  Future<String?> signInWithGoogle() async {
    try {
      // Aseguramos que esté inicializado antes de llamar a nada
      await _ensureInitialized();

      // 3. Ya no existe signIn(), ahora usamos authenticate()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        // scopeHint le dice a Google qué datos pediremos (email y perfil)
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      // Extraemos las credenciales (aquí está nuestro valioso idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      debugPrint(
        "✅ ÉXITO: Usuario de Google seleccionado -> ${googleUser.email}",
      );
      
      if (idToken != null) {
        debugPrint("==========================================");
        debugPrint("🔑 TAMAÑO DEL ID TOKEN: ${idToken.length}");
        debugPrint("=== INICIO DEL TOKEN (CÓPIALO COMPLETO) ===");
        final int chunkSize = 800;
        for (var i = 0; i < idToken.length; i += chunkSize) {
          debugPrint(idToken.substring(i, i + chunkSize > idToken.length ? idToken.length : i + chunkSize));
        }
        debugPrint("=== FIN DEL TOKEN ===");
        debugPrint("==========================================");
      }

      return idToken;
    } on GoogleSignInException catch (e) {
      // 4. Nuevo manejo de errores específico de la v7.x
      debugPrint("❌ Error Google Sign-In: ${e.code.name}");

      // Si el usuario simplemente cerró la ventana (canceló), retornamos null silenciosamente
      if (e.code.name == 'canceled' || e.code.name == 'sign_in_canceled') {
        return null;
      }
      throw Exception('Fallo al autenticar con Google');
    } catch (error) {
      debugPrint("❌ Error general en Google Sign-In: $error");
      throw Exception('Fallo inesperado al iniciar sesión');
    }
  }

  /// Cierra la sesión local de Google
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.disconnect();
  }
}
