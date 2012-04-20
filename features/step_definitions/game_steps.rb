def get_player(pnum)
  @game.playernum(pnum)
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


Given /^a new game$/ do
  @game = Game.create
end

When /^player (\d+) tries to start the game$/ do |pnum|
  player = @game.playernum(pnum).start_game
end

Then /^the game should still be in the setup phase$/ do
  @game.phase.should == 'setup'
end

When /^player (\d+) drafts "([^"]*)"$/ do |pnum, piece_name|
  get_player(pnum).draft(piece_name)
end

When /^player (\d+) indicates he is ready$/ do |pnum|
  get_player(pnum).get_ready
end

Then /^player (\d+) should not be ready$/ do |pnum|
  get_player(pnum).ready?.should be_false
end

Then /^player (\d+) should be ready$/ do |pnum|
  get_player(pnum).ready?.should be_true
end

When /^player (\d+) is chosen to go first$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^player (\d+) starts the game$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the game should not be in the setup phase$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+) should have a "([^"]*)" at "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+)s Nav should be at "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+)s keep should be full$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+)s graveyard should be empty$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

