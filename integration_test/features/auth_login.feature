Feature: Login de Usuario
  Como jugador de MatchDay
  Quiero iniciar sesión en la aplicación
  Para acceder a mis equipos y partidos

  Scenario: Login exitoso con credenciales correctas
    Given la app está en la pantalla de bienvenida
    When ingreso el correo "vellojindiego7@gmail.com"
    And ingreso la contraseña "Password123"
    And presiono el botón de iniciar sesión
    Then soy redirigido al Main Hub
    And veo mi nombre "Diego Vellojin" en el perfil
