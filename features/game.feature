Feature: Game 
  In order to have fun
  As a player
  I want to play a game

  Scenario: Begin a new game with default armies
    Given a new game
    When player 1 tries to start the game
    Then the game should still be in the setup phase
    When player 1 drafts "Tro"
    And player 1 drafts "Agu"
    And player 1 drafts "Ham"
    And player 1 drafts "Gar"
    And player 1 drafts "Neto"
    And player 1 drafts "Gun"
    And player 1 drafts "Est"
    And player 1 indicates he is ready
    Then player 1 should not be ready
    # (because he has only selected 6 creatures and a Nav)
    When player 2 drafts "Olp"
    And player 2 drafts "GilTwo"
    And player 2 drafts "Mses"
    And player 2 drafts "Nebgua"
    And player 2 drafts "Turtle"
    And player 2 drafts "Kap"
    And player 2 drafts "Kom"
    And player 2 indicates he is ready
    Then player 2 should not be ready
    # (because he hasn"t chosen a Nav)
    When player 2 drafts "Deb"
    And player 2 indicates he is ready
    Then player 2 should be ready
    And player 1 should not be ready
    When player 2 tries to start the game
    Then the game should still be in the setup phase
    When player 1 drafts "Tiny"
    And player 1 indicates he is ready
    Then player 1 should be ready
    And player 2 should be ready
    When player 1 is chosen to go first
    And player 2 starts the game
    Then the game should not be in the setup phase
    And the game should be in progress
    And player 1 should have a "BlackStone" at "c2"
    And player 1 should have a "RedStone" at "b1"
    And player 1s Nav should be at "d1"
    And player 1s keep should be full
    And player 1 should have 0 crystals
    And player 1s graveyard should be empty
    And player 2 should have a "BlackStone" at "d6"
    And player 2 should have a "RedStone" at "f7"
    And player 2s Nav should be at "d7"
    And player 2s keep should be full
    And player 2 should have 0 crystals
    And player 2s graveyard should be empty
    And it should be player 1s turn

