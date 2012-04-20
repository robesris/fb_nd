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
  @game.default_setup
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

When /^player (\d+) is chosen to go first$/ do |pnum|
  @game.active_player = get_player(pnum) 
  @game.save
end

When /^player (\d+) starts the game$/ do |pnum|
   player = get_player(pnum)
   @game.start_game
end

Then /^the game should not be in the setup phase$/ do
  @game.phase != 'setup'
end

Then /^player (\d+) should have a "([^"]*)" at "([a-g])([^"]*)"$/ do |pnum, piece_name, col, row|
  space = @game.board.spaces.where(:col => icol(col), :row => row.to_i).first
  space.piece.name.should == piece_name
  space.piece.player.should == get_player(pnum)
end

Then /^player (\d+)s Nav should be at "([a-g])([^"]*)"$/ do |pnum, col, row|
  player = get_player(pnum)
  player.nav.space.col.should == icol(col)
  player.nav.space.row.should == row.to_i
end

Then /^player (\d+)s keep should be full$/ do |pnum|
  player = get_player(pnum)
  player.keep_full?.should be_true
end

Then /^player (\d+)s graveyard should be empty$/ do |pnum|
  player = get_player(pnum)
  player.pieces.where(:in_graveyard => true).empty?
end

