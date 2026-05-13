Feature: Descubrimiento de Equipos
  Como jugador sin equipo
  Quiero explorar equipos que están reclutando
  Para unirme a uno y empezar a competir

  Scenario: Usuario busca y solicita unirse a un equipo
    Given estoy logueado en la aplicación
    When navego a la sección de "Equipos"
    Then veo una lista de equipos disponibles
    When selecciono el equipo "Manchester City"
    And presiono en "Solicitar Unirse"
    Then veo un mensaje de confirmación "Solicitud enviada con éxito"
