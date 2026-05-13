Feature: Creación de Partido por Capitán
  Como capitán de un equipo
  Quiero publicar un nuevo reto
  Para encontrar rivales y jugar

  Scenario: Capitán publica un partido exitosamente
    Given estoy logueado como capitán de un equipo
    When abro el formulario de creación de partido
    And selecciono el deporte "Pádel"
    And selecciono la cancha "Estadio Olímpico UCV"
    And presiono en "Publicar Partido"
    Then el partido aparece en mi lista de partidos activos
