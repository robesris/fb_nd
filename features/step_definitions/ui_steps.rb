def check_selenium_browsers
  Capybara.instance_variable_set('@current_driver', :selenium)
  if $browsers.nil?
    $browsers = {}
    current_url
    $browsers[1] = get_selenium_browser
    set_selenium_browser(nil)
    current_url
    $browsers[2] = get_selenium_browser
    set_selenium_browser(1)
  end
end

def get_selenium_browser
  {
    :session => Capybara.current_session,
    :driver  => Capybara::Driver::Selenium.instance_variable_get('@driver')
  }
end

def set_selenium_browser(browser_id)
  browser = $browsers[browser_id] || {}
  if browser[:session].nil?
    Capybara.instance_variable_set('@session_pool', {})
    Capybara::Driver::Selenium.instance_variable_set('@driver', nil)
  else
    Capybara.instance_variable_set('@session_pool', {"selenium#{Capybara.app.object_id}" => browser[:session]})
    Capybara::Driver::Selenium.instance_variable_set('@driver', browser[:driver])
  end
end

def my_browser
  check_selenium_browsers
  set_selenium_browser(@my_num)
end

def opponent_browser
  check_selenium_browsers
  set_selenium_browser(@opponent_num)
end

def get_empty_keep_space(pnum = 1)
  1.upto(7) do |n|
    keep_space = page.find_by_id("keep_#{pnum}_#{n}")
    return keep_space if keep_space.first('piece').nil?
  end
  return false
end

def current_game
  Game.first
end

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
  @me = :player1
  @my_num = 1
  @opponent = :player2
  @opponent_num = 2
  click_link "New Game"
end

When /^my opponent joins the game$/ do
  pending # express the regexp above with the code you wish you had
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
    @my_piece_names ||= []
    piece = page.find_by_id('draft_' + piece_name.downcase)
    empty_keep_space = get_empty_keep_space
    piece.drag_to(empty_keep_space)
    @my_piece_names << piece_name
  else
    @opponent_piece_names ||= []
    # do this on the backend since it's happening from the opponent's side
    #current_game.send(@opponent).draft(piece_name)
    
    @opponent_piece_names << piece_name
  end
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
  choose "game_active_player_go_first"
end

When /^I indicate that I am ready$/ do
  click_button "Ready"
end

When /^my opponent indicates that he is ready$/ do
  # just do this directly on the backend
  @game = Game.first
  @game.send(@opponent).update_attribute(:ready, true)
end

When /^I start the game$/ do
  click_button "Start"
end

Then /^I should see (my|my opponents) pieces in their starting positions$/ do |who|
  pnum = who == 'my' ? @my_num : @opponent_num
  row = pnum == 1 ? 1 : 7
  piece_names = who == 'my' ? @my_piece_names : @opponent_piece_names

  piece_names.each do |piece_name|
    page.find(:xpath, "//div[@id='keep_#{pnum}']//div[@name='#{piece_name}']")[:class].should have_content("player#{pnum}")
  end
end
