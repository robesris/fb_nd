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

  Scenario: Flip Agu and move with advanced movement, and capture
    Given an empty board
    And player 1 has an 'Agu' at 'a1'
    And player 1 has a 'BlackStone' at 'f2'
    And player 2 has a 'BlackStone' at 'g6'
    And player 1 has 15 crystals
    And player 2 has 0 crystals
    And it is player 1s turn
    When player 1 tries to move from 'a1' to 'a3'
    Then player 1 should have an 'Agu' at 'a1'
    When player 1 moves from 'f2' to 'f3'
    Then player 1 should have 16 crystals
    And it should be player 2s turn
    When player 2 moves from 'g6' to 'g5'
    Then player 2 should have 1 crystal
    And it should be player 1s turn
    When player 1 tries to move from 'a1' to 'c3'
    Then player 1 should have an 'Agu' at 'a1'
    When player 1 moves from 'a1' to 'b2' and does not pass the turn
    And player 1 tries to move from 'b2' to 'b3'
    Then player 1s 'Agu' should be at 'b2'
    When player 1 flips 'Agu'
    Then player 1 should have 0 crystals
    And player 1s 'Agu' should be at 'b2'
    And it should be player 2s turn
    When player 2 moves from 'g5' to 'g4'
    Then player 2 should have 2 crystals
    When player 1 moves from 'b2' to 'g2'
    Then player 1s 'Agu' should be at 'g2'
    When player 2 moves from 'g4' to 'g3'
    Then player 2 should have 3 crystals
    When player 1 tries to move from 'g2' to 'g4'
    Then player 1s 'Agu' should be at 'g2'
    When player 1 moves from 'g2' to 'g3'
    Then player 1 should have 1 crystal
    And player 2s 'BlackStone' should not be at 'g3'
    And player 2s 'BlackStone' should be in the graveyard
    And it should be player 2s turn

  Scenario: A flipped Gar captures the opponent's Nav and wins the game
    Given an empty board
    And player 1 has an 'Est' at 'e2'
    And player 1 has a 'Neto' at 'e4'
    And player 2 has a 'Deb' at 'a7'
    And player 2 has a 'Gar' at 'e6'
    And player 2s 'Gar' is flipped
    And it is player 2s turn
    When player 2 moves from 'e6' to 'e2'
    Then player 2s 'Gar' should be at 'e2'
    And player 1s 'Neto' should not be in the graveyard
    And player 1s 'Neto' should be at 'e4'
    And player 2 should win the game

  Scenario: Neto uses flip ability in half-crystal zone to return Gun from graveyard (after first trying to summon to illegal square)
    Given an empty board
    And player 1 has a 'Neto' at 'c4'
    And player 1 has a 'Gun' in the graveyard
    And it is player 1s turn
    And player 1 has 4 crystals
    When player 1 flips 'Neto'
    Then player 1s 'Neto' should be flipped
    When player 1 chooses player 1s 'Gun'
    And player 1 chooses 'a4'
    Then player 1s 'Gun' should be in the graveyard
    When player 1 chooses 'a2'
    Then player 1s 'Gun' should not be in the graveyard
    And player 1s 'Gun' should be at 'a2'
    And player 1s 'Neto' should not be at 'c4'
    And player 1s 'Neto' should be in the graveyard
    And player 1 should have 1 crystal

  Scenario: Players summon Olp and Tiny after attempting illegal moves, then Tiny flips to destroy Olp
    Given an empty board
    And player 1 has an 'Aio' at 'f2'
    And player 1 has an 'Olp' in his keep
    And player 1 has 0 crystals
    And player 2 has a 'Krr' at 'c7'
    And player 2 has a 'Tiny' in his keep
    And player 2 has 20 crystals
    And it is player 2s turn
    When player 2 tries to summon 'Tiny' to 'a2'
    Then player 2s 'Tiny' should be in his keep
    And player 2s 'Tiny' should not be at 'a2'
    When player 2 tries to summon 'Tiny' to 'c7'
    Then player 2s 'Tiny' should be in his keep
    And player 2s 'Tiny' should not be at 'a2'
    When player 2 summons 'Tiny' to 'b7'
    Then player 2s 'Tiny' should not be in his keep
    And player 2s 'Tiny' should be at 'b7'
    And it should be player 1s turn
    When player 1 tries to summon 'Olp' to 'a1'
    Then player 1s 'Olp' should be in his keep
    And player 1s 'Olp' should not be at 'a1'
    When player 1 summons 'Olp' to 'f3'
    Then player 1s 'Olp' should not be in his keep
    And player 1s 'Olp' should be at 'f3'
    And it should be player 2s turn
    When player 2 moves from 'b7' to 'b6' and does not pass the turn
    Then player 2s 'Tiny' should be at 'b6'
    When player 2 flips 'Tiny'
    And player 2 chooses player 1s 'Aio'
    Then it should be player 2s turn
    And player 1s 'Aio' should be at 'f2'
    And player 1s 'Aio' should not be in the graveyard
    And the game should be in progress
    When player 2 chooses player 1s 'Olp'
    Then player 1s 'Olp' should not be at 'f3'
    And player 1s 'Olp' should be in the graveyard
    And player 2s 'Tiny' should not be at 'b6'
    And player 2s 'Tiny' should be in the graveyard
    And player 1 should have 0 crystals
    And player 2 should have 6 crystals
    And it should be player 1s turn

  Scenario: Line Over and Goal Over
    Given an empty board
    And player 1 has a 'Chakra' at 'f7'
    And player 1 has a 'RedStone' at 'b7'
    And player 1 has a 'GilTwo' in his keep
    And player 1 has 58 crystals
    And player 2 has a 'Hill' at 'b1'
    And player 2 has 9 crystals
    And it is player 1s turn
    When player 1 tries to Goal Over
    Then player 1s 'Chakra' should be at 'f7'
    And the game should be in progress
    And it should be player 1s turn
    When player 1 Lines Over with his 'RedStone'
    And player 1 chooses 'crystals'
    Then player 1 should have 60 crystals
    And player 1s 'RedStone' should be in the graveyard
    And it should be player 2s turn
    When player 2 Goals Over
    Then player 2 should win the game
