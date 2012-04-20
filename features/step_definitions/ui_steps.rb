Given /^I am on the app homepage$/ do
  visit('/')
end

Then /^I should see a new gameboard$/ do
  'a'.upto('g') do |col|
    1.upto(7) do |row|
      page.should have_css("div##{col}#{row.to_s}")
    end
  end
end

When /^I create a new game$/ do
  click_link "New Game"
end

Then /^I should see the default setup$/ do
  'a'.upto('g') do |col|
    steps %Q{
      Then I should see player 1s "BlackStone" at "#{col}2"
      And I should see player 2s "BlackStone" at "#{col}6"
    }
  end

  ['b', 'f'].each do |col|
    steps %Q{
      Then I should see player 1s "RedStone" at "#{col}1"
      And I should see player 2s "RedStone" at "#{col}7"
    }
  end

  steps %Q{
    And I should have 0 crystals
    And my opponent should have 0 crystals
  }
end

Then /^I should see player (\d+)s "([^"]*)" at "([a-g])([^"]*)"$/ do |pnum, piece_name, col, row|
  space = get_player(pnum)

end

When /^I choose default starter army (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent chooses starter army (\d+)$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I choose to go first$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I indicate that I am ready$/ do
  pending # express the regexp above with the code you wish you had
end

When /^my opponent indicates that he is ready$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I start the game$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see my pieces in their starting positions$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see my opponents pieces in their starting positions$/ do
  pending # express the regexp above with the code you wish you had
end

