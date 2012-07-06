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

def default_game_in_progress
  game = Game.create
  game.update_attribute(:phase, 'play')
  game.update_attribute(:active_player, game.player2)
  game.update_attribute(:code, "default_game_in_progress")
  game.player1.update_attribute(:crystals, 8)
  game.player1.update_attribute(:secret, 'player_1_secretABC')
  game.player2.update_attribute(:crystals, 11)
  game.player2.update_attribute(:secret, 'player_2_secret123')

  pieces = [[{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>2, :col=>1, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>6, :col=>1, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>4, :col=>2, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>6, :col=>2, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>2, :col=>3, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>6, :col=>3, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>3, :col=>4, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>6, :col=>4, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>2, :col=>5, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>6, :col=>5, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>4, :col=>6, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>5, :col=>6, :pnum=>2}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>2, :col=>7, :pnum=>1}],
            [{:name=>"BlackStone", :flipped=>nil, :type=>"BlackStone", :in_graveyard=>nil}, {:row=>5, :col=>7, :pnum=>2}],
            [{:name=>"RedStone", :flipped=>nil, :type=>"RedStone", :in_graveyard=>nil}, {:row=>1, :col=>2, :pnum=>1}],
            [{:name=>"RedStone", :flipped=>nil, :type=>"RedStone", :in_graveyard=>nil}, {:row=>1, :col=>6, :pnum=>1}],
            [{:name=>"RedStone", :flipped=>nil, :type=>"RedStone", :in_graveyard=>nil}, {:row=>7, :col=>2, :pnum=>2}],
            [{:name=>"RedStone", :flipped=>nil, :type=>"RedStone", :in_graveyard=>true}, {:row=>nil, :col=>nil, :pnum=>2}],
            [{:name=>"Tro", :flipped=>nil, :type=>"Tro", :in_graveyard=>nil}, {:row=>3, :col=>5, :pnum=>1}],
            [{:name=>"Agu", :flipped=>nil, :type=>"Agu", :in_graveyard=>nil}, {:row=>-2, :col=>2, :pnum=>1}],
            [{:name=>"Ham", :flipped=>nil, :type=>"Ham", :in_graveyard=>nil}, {:row=>-2, :col=>3, :pnum=>1}],
            [{:name=>"Gar", :flipped=>nil, :type=>"Gar", :in_graveyard=>nil}, {:row=>-2, :col=>4, :pnum=>1}],
            [{:name=>"Neto", :flipped=>nil, :type=>"Neto", :in_graveyard=>nil}, {:row=>-2, :col=>5, :pnum=>1}],
            [{:name=>"Gun", :flipped=>nil, :type=>"Gun", :in_graveyard=>nil}, {:row=>-2, :col=>6, :pnum=>1}],
            [{:name=>"Tiny", :flipped=>nil, :type=>"Tiny", :in_graveyard=>nil}, {:row=>-2, :col=>7, :pnum=>1}],
            [{:name=>"Est", :flipped=>nil, :type=>"Est", :in_graveyard=>nil}, {:row=>1, :col=>4, :pnum=>1}],
            [{:name=>"Olp", :flipped=>nil, :type=>"Olp", :in_graveyard=>nil}, {:row=>9, :col=>1, :pnum=>2}],
            [{:name=>"GilTwo", :flipped=>nil, :type=>"GilTwo", :in_graveyard=>nil}, {:row=>7, :col=>7, :pnum=>2}],
            [{:name=>"Mses", :flipped=>nil, :type=>"Mses", :in_graveyard=>nil}, {:row=>9, :col=>3, :pnum=>2}],
            [{:name=>"Nebgua", :flipped=>nil, :type=>"Nebgua", :in_graveyard=>nil}, {:row=>9, :col=>4, :pnum=>2}],
            [{:name=>"Turtle", :flipped=>nil, :type=>"Turtle", :in_graveyard=>nil}, {:row=>9, :col=>5, :pnum=>2}],
            [{:name=>"Kap", :flipped=>nil, :type=>"Kap", :in_graveyard=>nil}, {:row=>9, :col=>6, :pnum=>2}],
            [{:name=>"Kom", :flipped=>nil, :type=>"Kom", :in_graveyard=>nil}, {:row=>9, :col=>7, :pnum=>2}],
            [{:name=>"Deb", :flipped=>nil, :type=>"Deb", :in_graveyard=>nil}, {:row=>7, :col=>4, :pnum=>2}]]
  
  pieces.each do |p|
    player = game.playernum(p.last[:pnum])
    piece = p.first[:name].constantize.create(p.first)
    if p.last[:row] && p.last[:col]
      space = Space.where(:col => p.last[:col], :row => p.last[:row]).first
      space.update_attribute(:piece, piece)
    end
    player.pieces << piece
  end

  game
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

When /^I join a game in progress$/ do
  my_browser

  @game = default_game_in_progress

  visit join_game_path(:game_code => @game.code, :player_secret => @game.player1.secret)
end

When /^(I|my opponent) flips? the "(.*?)" at "(.*?)"$/ do |who, piece_name, coords|
  browser(who)

  piece = piece_at(coords)
  find('#' + piece[:id]).click
end

When /^my opponent moves his "(.*?)" from "(.*?)" to "(.*?)" to capture$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see the captured piece in my graveyard$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I move my "(.*?)" from "(.*?)" to "(.*?)" to capture$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^both players should see my opponents "(.*?)" in my opponents graveyard$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^my opoonent moves his "(.*?)" from "(.*?)" to "(.*?)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent summons his "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I summon my "(.*?)" to "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent flips his "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^my opponent should have a choice to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^my opponent chooses his "(.*?)" at "(.*?)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^my opponent should still have a choice to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

