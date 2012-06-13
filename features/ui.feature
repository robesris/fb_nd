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

    # Make sure we can't draft more than 7 pieces
    #And I draft "Turtle"
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
    And my opponent drafts "Aio"

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
    
