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
    And my opponent indicates that he is ready
    And I start the game
    Then I should see my pieces in their starting positions
    And I should see my opponents pieces in their starting positions

