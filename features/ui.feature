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
    When my opponent moves from "f7" to "g6"
    And I wait 1 second
    Then both players should see my opponents "RedStone" at "g6"
    And both players should see 4 crystals in my opponents pool

    # my turn

    # summoning a guard

    # can't summon to a regular summon space
    When I try to summon "Tro" to "a1"
    And I wait 1 second
    Then both players should see no piece at "a1"

    # summon next to Nav
    When I summon "Tro" to "d2"
    Then both players should see my "Tro" at "d2"
    And both players should not see "Tro" in my keep

    # their turn
    
    # move a non-stone piece
    When my opponent moves his "GilTwo" from "g7" to "g6"

    # my turn
    # TO BE CONTINUED


