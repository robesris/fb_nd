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

Then /^(I|my opponent) should have (\d+) crystals$/ do |who, num|
  pnum = who == 'I' ? 1 : 2
  
  find(:xpath, "//input[@id='player#{pnum}_crystals']").value.should == num
end

Then /^I should see player (\d+)s "([^"]*)" at "([a-g])([^"]*)"$/ do |pnum, piece_name, col, row|
  page.should have_selector(:xpath, "//div[@id='space_#{col}_#{row}']/div[@name='#{piece_name}' and @class='player#{pnum}']")
end

When /^(I|my opponent) chooses? default starter army (\d+)$/ do |who, army_num|
  if army_num.to_i == 1
    steps %Q{
      When #{who} drafts "Tro"
      And #{who} drafts "Agu"
      And #{who} drafts "Ham"
      And #{who} drafts "Gar"
      And #{who} drafts "Neto"
      And #{who} drafts "Gun"
      And #{who} drafts "Tiny"
      And #{who} drafts "Est"
    }
  else
    steps %Q{
      When #{who} drafts "Olp"
      And #{who} drafts "GilTwo"
      And #{who} drafts "Mses"
      And #{who} drafts "Nebgua"
      And #{who} drafts "Turtle"
      And #{who} drafts "Kap"
      And #{who} drafts "Kom"
      And #{who} drafts "Deb"
    }
  end
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

