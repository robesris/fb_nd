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
    And player 2 should have 5 crystals

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
    When player 1 moves from 'd4' to 'g1'
    Then player 1s 'Ham' should be at 'd4'
    And player 1s 'Ham' should not be at 'g1'
    And player 2s 'Tro' should be at 'f2'

  Scenario: Player 2's Red Stone (e.g. with a reversed grid) can move and capture as expected
    Given an empty board
    And player 1 has a 'Mses' at 'g1'
    And player 2 has a 'RedStone' at 'e5'
    And player 1 has 25 crystals
    And player 2 has 3 crystals
    And it is player 1s turn
    When player 1 moves from 'g1' to 'g2'
    And player 2 tries to move from 'e5' to 'e6'
    Then player 2 should have 3 crystals
    And player 2s 'RedStone' should be at 'e5'
    And it should be player 2s turn

    When player 2 moves from 'e5' to 'f4'
    Then player 2 should have 6 crystals
    And player 2s 'RedStone' should be at 'f4'
    And it should be player 1s turn

    When player 1 moves from 'g2' to 'g3'
    Then player 1 should have 25 crystals
    And player 1s 'Mses' should be at 'g3'
    And it should be player 2s turn

    When player 2 moves from 'f4' to 'g3'
    Then player 2 should have 19 crystals
    And player 1 should have 25 crystals
    And player 2s 'RedStone' should be at 'g3'
    And player 1s 'Mses' should not be at 'g3'
    And player 1s 'Mses' should be in the graveyard
    And it should be player 1s turn



