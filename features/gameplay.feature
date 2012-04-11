Feature: Gameplay
  As a player
  In order to play the game
  I want to make moves

  Scenario: Capture a flipped Tro with a Black Stone
    Given an empty board
    And player 1 has a 'Tro' at 'c3'
    And player 1s 'Tro' is flipped
    And player 2 has a 'BlackStone' at 'c4'
    And player 1 has 0 crystals
    And player 2 has 0 crystals
    And the graveyard is empty
    And it is player 2s turn
    When player 2 moves from 'c4' to 'c3'
    Then player 1s 'Tro' should be in the graveyard
    And players 2s 'BlackStone' should be at 'c3'
    And player 1 should have 10 crystals
    And player 2 should have 1 crystal
