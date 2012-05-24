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
    
