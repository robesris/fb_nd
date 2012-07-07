Feature: User interface
  As a user
  In order to play the game
  I want to be able to interact with the game through a browser

  @javascript
  Scenario: Start a new game
    Given I am on the app homepage
    When I create a new game
    Then I should see the default setup
    When my opponent joins the game
    And I choose default starter army 1
    And my opponent chooses default starter army 2
    And I choose to go first
    And I indicate that I am ready
    Then I should see my pieces in their starting positions
    And my opponent should see their pieces in their starting positions
    And I should not see my opponents pieces in their starting positions
    And my opponent should not see my pieces in their starting positions
    When my opponent indicates that he is ready
    Then I should see my pieces in their starting positions
    And my opponent should see their pieces in their starting positions
    And I should see my opponents pieces in their starting positions
    And my opponent should see my pieces in their starting positions
    And there should be exactly one piece on each keep space in both browsers

  @javascript
  Scenario: Try to make some illegal drafts
    Given I am on the app homepage
    When I create a new game
    Then I should see the default setup
    When my opponent joins the game
    And I draft "Olp" to "c_1"
    And I draft "GilTwo" to "f_3"
    Then both players should see nothing at "c_1"
    And both players should see nothing at "f_3"

    # Should be able to draft 2 of a single piece per player, but not more
    When I draft "Nebgua"
    # the following draft should succeed
    And I draft "Nebgua"
    And I draft "Mses"
    And I draft "Nebgua"
    And my opponent drafts "Kom"
    And my opponent drafts "Nebgua"
    And my opponent drafts "Nebgua"

    # the following three drafts should fail
    And my opponent drafts "Aio" to "keep_2_4"
    And my opponent drafts "Nebgua"
    And my opponent drafts "Tro" to "keep_2_1"

    And my opponent drafts "Neto"
    Then I should see nothing at "keep_1_4"
    And my opponent should see nothing at "keep_2_5"
    When I draft "GilTwo"
    And I draft "Ham"
    And I draft "Ham"
    And I draft "Gun"
    And I draft "Aio"
    And my opponent drafts "Tiny"
    And my opponent drafts "Olp"
    And my opponent drafts "Gar"
    And my opponent drafts "Aio" to "keep_1_7"
    And my opponent drafts "Chakra" to "keep_2_7"

    # the following two drafts should fail
    And my opponent drafts "Aio" to "d_1"
    And my opponent drafts "Aio" to "a_5"

    And my opponent drafts "Aio" to "e_3"
    And my opponent drafts "Aio" to "d_7"

    # the following draft should fail
    And my opponent drafts "Hill"
    
    And I indicate that I am ready
    And my opponent indicates that he is ready
    Then both players should see player 1s "Nebgua" at "keep_1_1"
    And both players should see player 1s other "Nebgua" at "keep_1_2"
    And both players should see player 1s "Mses" at "keep_1_3"
    And both players should see player 2s "Kom" at "keep_2_1"
    And both players should see player 2s "Nebgua" at "keep_2_2"
    And both players should see player 2s other "Nebgua" at "keep_2_3"
    And both players should see player 2s "Neto" at "keep_2_4"
    And there should be exactly one piece on each keep space in both browsers

  @javascript
  Scenario: Start the game and make some moves
    When I begin a new game
    Then both players should not see the draft list
    And I wait 2 seconds
    When I move the "BlackStone" at "b2" to "b3"
    Then both players should see that piece at "b3"
    And both players should see no piece at "b2"
    And both players should see 1 crystal in my pool

    # try moving again even though it's not my turn
    When I move the "RedStone" at "b1" to "b2"
    Then both players should see 1 crystal in my pool
    And both players should see my "RedStone" at "b1"
    And both players should see no piece at "b2"

    # summoning
    When my opponent summons "GilTwo" to "g7"
    Then both players should see 0 crystals in my opponents pool
    And both players should see my opponents "GilTwo" at "g7"

    # my turn

    # illegal move - not my opponent's turn
    When my opponent tries to move the "BlackStone" at "g6" to "g5"
    Then both players should see 0 crystals in my opponents pool
    And both players should see my opponents "BlackStone" at "g6"
    And both players should see no piece at "g5"

    # illegal move - piece can't move like that
    When I try to move from "c2" to "c4"
    Then both players should see no piece at "c4"
    And both players should see my "BlackStone" at "c2"

    # opponent tries to move
    When my opponent tries to move from "g7" to "c4"
    Then both players should see no piece at "c4"
    And both players should see my opponents "GilTwo" at "g7"

    # legal move
    When I move from "b3" to "b4"
    Then both players should see 2 crystals in my pool
    And both players should see my "BlackStone" at "b4"

    # can't make this move because not flipped yet
    When my opponent tries to move from "g7" to "c4"
    Then both players should still see my opponents "GilTwo" at "g7"

    When my opponent moves the "BlackStone" at "g6" to "g5"
    Then both players should see 1 crystal in my opponents pool
    And both players should see my opponents "BlackStone" at "g5"

    # my turn
    When I move from "d2" to "d3"
    Then both players should see 3 crystals in my pool

    # their turn
    
    # can't capture your own piece
    When my opponent tries to move the "RedStone" at "f7" to "f6"
    Then both players should see my opponents "RedStone" at "f7"
    And both players should see my opponents "BlackStone" at "f6"
    And both players should see 1 crystal in my opponents pool

    # legal move
    And I wait 2 seconds
    When my opponent moves from "f7" to "g6"
    And I wait 4 seconds
    Then both players should see my opponents "RedStone" at "g6"
    And both players should see 4 crystals in my opponents pool
    
    # my turn

    # summoning a guard

    # can't summon to a regular summon space
    When I try to summon "Tro" to "a1"
    And I wait 2 seconds
    Then both players should see no piece at "a1"

    # summon next to Nav
    When I summon "Tro" to "d2"
    Then both players should see my "Tro" at "d2"
    And both players should not see "Tro" in my keep

    # their turn
    
    # move a non-stone piece; can't capture your own piece
    When my opponent tries to move his "GilTwo" from "g7" to "g6"
    Then both players should see my opponents "GilTwo" at "g7"
    And both players should see my opponents "RedStone" at "g6"
    And it should be my opponents turn

    When my opponent moves his "RedStone" from "g6" to "f5"
    Then both players should see 7 crystals in my opponents pool
    And I wait 1 second
    And it should be my turn

    # my turn
    When I move my "Tro" from "d2" to "e3"
    Then it should still be my turn
    #And I allow user input
    When I try to flip the "Tro" at "e3"
    Then both players should see that piece unflipped

    When I try to move the "Est" at "d1" to "c1"
    Then both players should see my "Est" at "d1"
    And both players should see no piece at "c1"

    When I pass the turn
    And I wait 2 seconds
    Then it should be my opponents turn

    # their turn
    When my opponent moves the "RedStone" at "f5" to "f4"
    And I wait 2 seconds
    Then both players should see 10 crystals in my opponents pool
    
    When my opponent passes the turn

    # my turn
    And I move the "BlackStone" at "f2" to "f3"
    Then both players should see 4 crystals in my pool

    # their turn
    When my opponent moves the "BlackStone" at "f6" to "f5"
    Then both players should see 11 crystals in my opponents pool

    # my turn - capture RedStone!
    When I move the "BlackStone" at "f3" to "f4"
    And I wait 2 seconds
    Then both players should see my opponents "RedStone" in their graveyard
    And both players should see my "BlackStone" at "f4"
    And both players should see 8 crystals in my pool
    And it should be my opponents turn

  @javascript
  Scenario: Start the game and make some moves (continued)
    When I join a game in progress
    And my opponent joins the game in progress
    Then it should be my opponents turn
    And both players should not see the draft list

    When my opponent moves his "GilTwo" from "g7" to "f6"
    And my opponent flips the "GilTwo" at "f6"
    And I wait 1 second
    Then both players should see that piece flipped
    And both players should see 0 crystals in my opponents pool
    And it should be my turn

    When I flip the "Tro" at "e3"
    And I wait 1 second
    Then both players should see that piece flipped
    And both players should see 4 crystals in my pool
    And it should be my opponents turn

    When my opponent moves his "GilTwo" from "f6" to "f4" to capture
    Then both players should see the captured piece in my graveyard
    And both players should see my opponents "GilTwo" at "f4"
    And both players should see 1 crystal in my opponents pool

    When my opponent passes the turn
    And it should be my turn

    When I move my "Tro" from "e3" to "f4" to capture
    Then both players should see my opponents "GilTwo" in the graveyard
    And both players should see my "Tro" at "f4"
    And both players should see 15 crystals in my pool
    And it should be my opponents turn

    When my opponent moves his "BlackStone" from "d6" to "d5"
    Then both players should see 2 crystals in my opponents pool
    And it should be my turn


    #And I allow user input
    When I move my "Est" from "d1" to "d2"
    And I pass the turn
    And I wait 1 second
    Then both players should see my "Est" at "d2"
    And it should be my opponents turn

    # Tro's ability
    When my opponent moves his "BlackStone" from "f5" to "f4"
    Then both players should see my "Tro" in my graveyard
    And both players should see 7 crystals in my opponents pool
    And both players should see 25 crystals in my pool
    And it should be my turn

    When I move from "a2" to "a3"
    And I wait 1 second
    Then both players should see 26 crystals in my pool
    And it should be my opponents turn

    When my opponent summons his "Olp" to "d6"
    Then both players should see my opponents "Olp" at "d6"
    And it should be my turn

    When I summon my "Tiny" to "a2"
    And I wait 1 second
    Then it should be my opponents turn

    # A flip that requires a choice
    When my opponent flips the "Olp" at "d6"
    Then it should still be my opponents turn
    And my opponent should have a choice to "Choose a piece."

    # Can't choose a Nav
    When my opponent chooses his "Deb" at "d7"
    Then my opponent should still have a choice to "Choose a piece."

    When my opponent chooses his "Olp" at "d6"
    Then my opponent should have a choice to "Choose a piece to switch it with."

    # Can't choose a Nav
    When my opponent chooses his "Deb" at "d7"
    Then my opponent should still have a choice to "Choose a piece to switch it with."

    When my opponent chooses his "BlackStone" at "f4"
    Then both players should see my opponents "Olp" at "f4"
    And both players should see my opponents "BlackStone" at "d6"
    And both players should see 2 crystals in my opponents pool
    And it should be my turn

    When I move my "RedStone" from "b1" to "b2"
    Then both players should see 28 crystals in my pool
    And it should be my opponents turn

    When my opponent moves his "BlackStone" from "b6" to "b5"
    Then both players should see 3 crystals in my opponents pool

    # TO BE CONTINUED...
