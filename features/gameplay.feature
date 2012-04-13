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
    And player 2s 'BlackStone' should be at 'c3'
    And player 1 should have 10 crystals
    And player 2 should have 1 crystal

  Scenario: Jump a Ham over a Red Stone
    Given an empty board
    And player 1 has a 'Ham' at 'a4'
    And player 2 has a 'RedStone' at 'b5'
    And player 1 has 0 crystals
    And player 2 has 50 crystals
    And it is player 1s turn
    And player 1 moves from 'a4' to 'c6'
    Then player 1s 'Ham' should be at 'c6'
    And player 2s 'RedStone' should be at 'b5'
    And player 1 should have 0 crystals
    And player 2 should have 50 crystals

  Scenario: Ham tries to move too far
    Given an empty board
    And player 1 has a 'Ham' at 'd4'
    And player 2 has a 'Tro' at 'f2'
    And player 1 moves from 'd4' to 'g1'
    Then player 1s 'Ham' should be at 'd4'
    And player 1s 'Ham' should not be at 'g1'
    And player 2s 'Tro' should be at 'f2'

