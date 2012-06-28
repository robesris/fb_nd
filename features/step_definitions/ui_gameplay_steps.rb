def piece_at(coords)
  space = get_space(coords)
  if space.has_xpath?('div')
    space.find(:xpath, 'div')
  else
    nil
  end
end

def empty?(coords)
  space = get_space(coords)
  space.has_no_xpath?('div')
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

When /^(I|my opponent)(?:| try to| tries to) moves? the "(.*?)" at "(.*?)" to "(.*?)"$/ do |who, piece_name, from_space, to_space|
  browser(who)
  
  @piece = piece_at(from_space)
  @piece[:name].should == piece_name

  @piece.drag_to(get_space(to_space))
end

When /^(I|my opponent)(?:| try to| tries to) moves? (?:my|his) "(.*?)" from "(.*?)" to "(.*?)"$/ do |who, piece_name, from_space, to_space|
  steps %Q{
    When #{who} moves the "#{piece_name}" at "#{from_space}" to "#{to_space}"
  }
end

Then /^(I|my opponent) (should|should not) see that piece at "(.*?)"$/ do |who, should, coords|
  browser(who)
  
  if should == 'should'
    puts "#{who} should..."
    piece_at(coords).should_not be_nil
    piece_at(coords)[:id].should == @piece[:id]
  else
    puts "#{who} should not..."
    if piece_at(coords)
      piece_at(coords)[:id].should_not == @piece[:id]
    end
  end
end

Then /^both players should see that piece at "(.*?)"$/ do |coords|
  steps %Q{
    Then I should see that piece at "#{coords}"
    And my opponent should see that piece at "#{coords}"
  }
end

Then /^(I|my opponent) should see no piece at "(.*?)"$/ do |who, coords|
  browser(who)

  empty?(coords).should be_true
end

Then /^(I|my opponent) should see (\d+) crystals? in (my|my opponents) pool$/ do |who, num, whose|
  browser(who)

  pnum = whose == 'my' ? 1 : 2

  #page.find_by_id("crystals_#{pnum}").text.should == num
  page.should have_xpath("//span[@id='crystals_#{pnum}' and text()='#{num}']")
end

Then /^both players should see no piece at "(.*?)"$/ do |coords|
  steps %Q{
    Then I should see no piece at "#{coords}"
    And my opponent should see no piece at "#{coords}"
  }
end

Then /^both players should see (\d+) crystals? in (my|my opponents) pool$/ do |num, whose|
  steps %Q{
    Then I should see #{num} crystals in #{whose} pool
    And my opponent should see #{num} crystals in #{whose} pool
  }
end

Then /^both players should (?:|still )see (my|my opponents) "(.*?)" at "(.*?)"$/ do |whose, piece_name, coords|
  @piece = piece_at(coords)
  @piece.should_not be_nil
  pnum = whose == 'my' ? 1 : 2
  @piece['data-owner'].should == pnum.to_s

  steps %Q{
    Then I should see that piece at "#{coords}"
    Then my opponent should see that piece at "#{coords}"
  }
end

When /^(I|my opponent) (?:|try to |tries to )summons? "(.*?)" to "(.*?)"$/ do |who, piece_name, coords|
  browser(who)

  pnum = who == 'I' ? 1 : 2
  #keep = page.find_by_id("keep_#{pnum}")
  @piece = page.find(:xpath, "//div[@id='keep_#{pnum}']/div/div[@name='#{piece_name}']")
  @piece.drag_to(get_space(coords))
end

When /^(I|my opponent)(?:| try to| tries to) moves? from "(.*?)" to "(.*?)"$/ do |who, from_coords, to_coords|
  browser(who)

  @piece = piece_at(from_coords)
  @piece.drag_to(get_space(to_coords))
end

Then /^(I|my opponent) should not see "(.*?)" in (my|my opponents) keep$/ do |who, piece_name, whose|
  browser(who)

  pnum = whose == 'my' ? 1 : 2
  page.should_not have_xpath("//keep_#{pnum}/div/div[@name='Tro']")
end

Then /^both players should not see "(.*?)" in (my|my opponents) keep$/ do |piece_name, whose|
  steps %Q{
    Then I should not see "#{piece_name}" in #{whose} keep
    And my opponent should not see "#{piece_name}" in #{whose} keep
  }
end

Then /^it should(?:| still) be (my|my opponents) turn$/ do |whose|
  my_browser
  page.find_by_id('active_player_text').text.should == "#{whose == 'my' ? 'Your Turn' : 'Opponent\'s Turn'}"
  opponent_browser
  page.find_by_id('active_player_text').text.should == "#{whose == 'my' ? 'Opponent\'s Turn' : 'Your Turn' }"
end

When /^(I|my opponent) (?:|try |tries )to flip the "(.*?)" at "(.*?)"$/ do |who, piece_name, coords|
  browser(who)

  @piece = piece_at(coords)
  @piece[:name].should == piece_name

  click_button('Flip Piece')
end

Then /^both players should see that piece (|un)flipped$/ do |flip_state|
  [:my_browser, :opponent_browser].each do |whose|
    send(whose)

    if flip_state.blank?
      @piece.find('.compass')[:src].should have_content('_flipped')
    else
      @piece.find('.compass')[:src].should_not have_content('_flipped')
    end
  end
end

When /^(I|my opponent) pass(?:|es) the turn$/ do |who|
  browser(who)

  click_button("End Turn")
end

Then /^(I|my opponent) should see (my|my opponents) "(.*?)" in the graveyard$/ do |who, whose, piece_name|
  browser(who)
  pnum = whose == 'my' ? 1 : 2

  page.should have_xpath("//div[@id='graveyard_#{pnum}']/div[@name='#{piece_name}']")
end

Then /^both players should see (my|my opponents) "(.*?)" in (?:my|their|the) graveyard$/ do |whose, piece_name|
  steps %Q{
    Then I should see #{whose} "#{piece_name}" in the graveyard
    And my opponent should see #{whose} "#{piece_name}" in the graveyard
  }
end



