def piece_at(coords)
  space = get_space(coords)
  if space.has_xpath?('div')
    space.find(:xpath, 'div')
  else
    nil
  end
end

When /^I begin a new game$/ do
  steps %Q{
    When I am on the app homepage
    And I create a new game
    Then I should see the default setup

    And my opponent joins the game
    And I choose default starter army 1
    And my opponent chooses default starter army 2
    And I choose to go first
    And I indicate that I am ready
    And my opponent indicates that he is ready
  }
end

Then /^(I|my opponent) (should|should not) see the draft list$/ do |who, should|
  browser(who)
  if should == 'should'
    # might have problems with this depending on how jquery hides/shows
    page.find(:xpath, "//div[@id='draft_section']")[:style].should_not have_content("display: none")
  else
    page.find(:xpath, "//div[@id='draft_section']")[:style].should have_content("display: none")
  end
end 

Then /^both players should not see the draft list$/ do
  steps %Q{
    Then I should not see the draft list
    And my opponent should not see the draft list
  }
end

When /^I move the "(.*?)" at "(.*?)" to "(.*?)"$/ do |piece_name, from_space, to_space|
  my_browser
  
  @piece = piece_at(from_space)
  @piece[:name].should == piece_name

  @piece.drag_to(get_space(to_space))
end

Then /^(I|my opponent) (should|should not) see that piece at "(.*?)"$/ do |who, should, coords|
  browser(who)

  if should == 'should'
    piece_at(coords)[:id].should == @piece[:id]
  else
    piece_at(coords)[:id].should_not == @piece[:id]
  end
end

Then /^both players should see that piece at "(.*?)"$/ do |coords|
  steps %Q{
    Then I should see that piece at "#{coords}"
    And my opponent should see that piece at "#{coords}"
  }
end

Then /^both players should see no piece at "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see (\d+) crystal in my pool$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see my "(.*?)" at "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent summons "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see (\d+) crystals in my opponents pool$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see my opponents "(.*?)" at "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent tries to move the "(.*?)" at "(.*?)" to "(.*?)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When /^I try to move from "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent tries to move from "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I move from "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see (\d+) crystals in my pool$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should still see my opponents "(.*?)" at "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent moves the "(.*?)" at "(.*?)" to "(.*?)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see (\d+) crystal in my opponents pool$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent moves from "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I try to summon "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I summon "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should not see "(.*?)" in my keep$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent moves his "(.*?)" from "(.*?)" to "(.*?)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

