def my_browser
  Capybara.session_name = :my_browser
end

def opponent_browser
  Capybara.session_name = :opponent_browser
end

def browser(who)
  who == 'I' ? my_browser : opponent_browser
end

def is_nav?(piece_name)
  Kernel.const_get(piece_name) < Piece::Nav
end

def nav_space_id(pnum)
  pnum == 1 ? "space_d_1" : "space_d_7"
end

def my_nav_space
  page.find_by_id(nav_space_id(@my_num))
end

def opponent_nav_space
  page.find_by_id(nav_space_id(@opponent_num))
end

def get_empty_keep_space(pnum = 1)
  1.upto(7) do |n|
    keep_space = page.find_by_id("keep_#{pnum}_#{n}")
    return keep_space if keep_space.first('div').nil?
  end
  return false
end

def current_game
  Game.first
end

Given /^I am on the app homepage$/ do
  @me = :player1
  @my_num = 1
  @opponent = :player2
  @opponent_num = 2

  my_browser

  visit('/')
end

When /^I visit the app homepage$/ do
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

When /^I join game "([^"]*)" as a new player$/ do |game_code|
  visit join_game_path(:game_code => game_code, :player_secret => 'new_player')
end

When /^my opponent joins the game$/ do
  opponent_browser

  @game_code ||= current_game.code
  steps %Q{
    When I visit the app homepage
    And I join game "#{@game_code}" as a new player
  }
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
  page.find(:xpath, "//div[@id='space_#{col}_#{row}']/div[@name='#{piece_name}']")[:class].should have_content("player#{pnum}")
end

When /^(I|my opponent) drafts "([^"]*)"$/ do |who, piece_name|
  if who == 'I'
    my_browser
    @my_piece_names ||= []
    piece = page.find_by_id('draft_' + piece_name.downcase)
    space = if piece[:class].include?('nav')
      my_nav_space
    else
      get_empty_keep_space
    end
    piece.drag_to(space)
    @my_piece_names << piece_name
  else
    opponent_browser
    @opponent_piece_names ||= []
    piece = page.find_by_id('draft_' + piece_name.downcase)
    space = if piece[:class].include?('nav')
      opponent_nav_space
    else
      get_empty_keep_space(2)
    end
    piece.drag_to(space)
    @opponent_piece_names << piece_name
  end
end

When /^(I|my opponent) chooses? default starter army (\d+)$/ do |who, army_num|
  browser(who)

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
  my_browser
  choose "game_active_player_go_first"
end

When /^I indicate that I am ready$/ do
  my_browser
  click_button "Ready"
end

When /^my opponent indicates that he is ready$/ do
  opponent_browser
  # just do this directly on the backend
  @game = Game.first
  @game.send(@opponent).update_attribute(:ready, true)
end

When /^I start the game$/ do
  my_browser

  click_link "Start"
end

Then /^(I|my opponent) should(| not) see (my|my opponents|their) pieces in their starting positions$/ do |who, should_val, whose|
  browser(who)

  should_see = should_val == ' not' ? false : true
  pnum = whose == 'my' ? @my_num : @opponent_num
  row = pnum == 1 ? 1 : 7
  piece_names = whose == 'my' ? @my_piece_names : @opponent_piece_names

  # I should/should not see each piece
  piece_names.each do |piece_name|
    if is_nav?(piece_name)
      xpath = "//div[@id='#{nav_space_id(pnum)}']/div"

      if should_see
        page.find(:xpath, xpath)[:class].should have_content("player#{pnum}")
      else
        page.should have_no_xpath(xpath)
      end
    else
      xpath = "//div[@id='keep_#{pnum}']//div[@name='#{piece_name}']"

      if should_see
        page.find(:xpath, xpath)[:class].should have_content("player#{pnum}")
      else
        page.should have_no_xpath(xpath)
      end
    end
  end

  # Each keep space should be filled
  1.upto(7) do |n|
    xpath = "//div[@id='keep_#{pnum}']/div[@id='keep_#{pnum}_#{n}']/div"

    if should_see
      page.find(:xpath, xpath)[:class].should have_content("piece")
    else
      page.should have_no_xpath(xpath)
    end
  end

  xpath = "//div[@id='#{nav_space_id(pnum)}']/div"

  if should_see
    page.find(:xpath, xpath)[:class].should have_content("nav")
  else
    page.should have_no_xpath(xpath)
  end
end

Then /^there should be exactly one piece on each keep space in both browsers$/ do
  my_browser
  1.upto(7) do |n|
    1.upto(2) do |p|
      pieces = page.find(:xpath, "//div[@id='keep_#{p}_#{n}']").all(:xpath, "./div")
      #debugger if pieces.size != 1
      pieces.size.should == 1
    end
  end

  opponent_browser
  1.upto(7) do |n|
    1.upto(2) do |p|
      page.find(:xpath, "//div[@id='keep_#{p}_#{n}']").all(:xpath, "./div").size.should == 1
    end
  end
end
