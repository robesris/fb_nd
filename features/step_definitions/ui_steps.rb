P1KROW = 0
P2KROW = 8

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

def getcol(col)
  if col.is_a?(String)
    col.ord - 96
  else
    col
  end
end

def get_keep_space(keep_id)
  page.find_by_id(keep_id)
end

def get_space(coords)
  if coords.slice(0, 4) == 'keep'
    space = get_keep_space(coords)
  else
    col = coords.first
    row = coords.last.to_i

    if row == P1KROW  # p1 keep space
      space = page.find_by_id("keep_1_#{getcol(col)}")
    elsif row == P2KROW # p2 keep space
      space = page.find_by_id("keep_2_#{getcol(col)}")
    else
      space = page.find_by_id("space_#{col}_#{row}")
    end
  end
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
  
  page.find_by_id("crystals_#{pnum}").text.to_i.should == num.to_i
end

Then /^(I|my opponent) should see player (\d+)s "(.*?)" at "keep_(\d+)_(\d+)"$/ do |who, pnum, piece_name, keep_num, keep_space_num|
  browser(who)
  page.find(:xpath, "//div[@id='keep_#{keep_num}_#{keep_space_num}']/div[@name='#{piece_name}']")[:class].should have_content("player#{pnum}")
end

Then /^(I|my opponent) should see player (\d+)s "([^"]*)" at "([a-g])([^"]*)"$/ do |who, pnum, piece_name, col, row|
  browser(who)
  page.find(:xpath, "//div[@id='space_#{col}_#{row}']/div[@name='#{piece_name}']")[:class].should have_content("player#{pnum}")
end

Then /^(I|my opponent) should see nothing at "(.*?)"$/ do |who, coords|
  browser(who)  
  space = get_space(coords)
  space.should have_no_xpath("/div")
end

When /^(I|my opponent) drafts? "([^"]*)"(?:()| to "(.*?)")$/ do |who, piece_name, junk, destination_space|
  if who == 'I'
    my_browser
    sleep(1) if @my_last_draft == piece_name
    @my_piece_names ||= []
    piece = page.find_by_id('draft_' + piece_name.downcase)
    space = if destination_space
      get_space(destination_space)
    elsif piece[:class].include?('nav')
      my_nav_space
    else
      get_empty_keep_space
    end
    piece.drag_to(space)
    @my_piece_names << piece_name
    @my_last_draft = piece_name
  else
    opponent_browser
    sleep(1) if @opponent_last_draft == piece_name
    @opponent_piece_names ||= []
    piece = page.find_by_id('draft_' + piece_name.downcase)
    space = if destination_space
      get_space(destination_space)
    elsif piece[:class].include?('nav')
      opponent_nav_space
    else
      get_empty_keep_space(2)
    end
    piece.drag_to(space)
    @opponent_piece_names << piece_name
    @opponent_last_draft = piece_name
  end
  sleep(0.5)
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
  click_button "Ready"
end

#When /^I start the game$/ do
#  my_browser
#
#  click_link "Start"
#end

Then /^both players should see nothing at "(.*)"$/ do |space|
  steps %Q{
    Then I should see nothing at "#{space}"
    And my opponent should see nothing at "#{space}"
  }
end

Then /^both players should see player (\d+)s "(.*?)" at "(.*?)"$/ do |pnum, piece_name, space|
  #debugger
  steps %Q{
    Then I should see player #{pnum}s "#{piece_name}" at "#{space}"
    And my opponent should see player #{pnum}s "#{piece_name}" at "#{space}"
  }
end

Then /^both players should see player (\d+)s other "(.*?)" at "(.*?)"$/ do |pnum, piece_name, space|
  steps %Q{
    Then I should see player #{pnum}s "#{piece_name}" at "#{space}"
    And my opponent should see player #{pnum}s "#{piece_name}" at "#{space}"
  }
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
      img_xpath = "#{xpath}/img[@src='/assets/#{piece_name.downcase}_#{pnum}.gif']"

      if should_see
        page.should have_xpath(img_xpath)
        page.find(:xpath, xpath)[:class].should have_content("player#{pnum}")
      else
        page.should have_no_xpath(xpath)
      end
    else
      xpath = "//div[@id='keep_#{pnum}']//div[@name='#{piece_name}']"
      img_xpath = "#{xpath}/img[@src='/assets/#{piece_name.downcase}_#{pnum}.gif']"

      if should_see
        page.should have_xpath(img_xpath)
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

  # Should see a Nav in the right space
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
