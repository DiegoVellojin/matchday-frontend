Feature: Creación de Equipo
  Como jugador registrado
  Quiero crear mi propio equipo
  Para organizar partidos y competir

  Scenario: Usuario crea un equipo exitosamente
    Given estoy logueado como capitán de un equipo
    When navego a la sección de "Equipos"
    And abro el formulario de creación de equipo
    And ingreso el nombre del equipo "Test FC E2E"
    And presiono en "Crear Equipo & Invitar Amigos"
    Then el equipo aparece en mi lista de "Mis Equipos"
