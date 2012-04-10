Given /^an empty board$/ do
  @game = Game.new(:player1 => Player.create, :player2 => Player.create)
  @game.save
  @player = [nil, { :pieces => {} }, { :pieces => {} }]
end

Given /^player (\d+) has a '(.*)' at '([a-g])(\d+)'$/ do |pnum, piece_name, row, col|
  piece = Kernel.const_get(piece_name.humanize).new
  piece.row = row
  piece.col = col
  piece.save
  puts @game.inspect
  @game.playernum(pnum).pieces << piece
  @player[pnum.to_i][:pieces][piece_name] = piece
end

Given /^player (\d+)s '(.*)' is flipped$/ do |pnum, piece_name|
  piece = @player[pnum.to_i][:pieces][piece_name]
  piece.flipped = true
  piece.save
end

Given /^player (\d+) has (\d+) crystals$/ do |pnum, num|
  player = @game.player(pnum.to_i)
  player.crystals = num
  player.save
end

Given /^the graveyard is empty$/ do
  @game.graveyard.empty
end

Given /^it is player (\d+)s turn$/ do |pnum|
  @game.active_player = pnum
end

When /^player (\d+) moves from '([a-g])(\d+)' to '([a-g])(\d+)'$/ do |pnum, row1, col1, row2, col2|
  @game.move(row1, col1, row2, col2)
end

Then /^player (\d+)s '(.*)' should be in the graveyard$/ do |pnum, piece_name|
  @player[pnum][pieces][piece_name].space.should == :graveyard
  @player[pnum][pieces][piece_name].row.should == GRAVEYARD
  @player[pnum][pieces][piece_name].col.should == GRAVEYARD
end

Then /^players (\d+)s 'Black Stone' should be at 'c(\d+)'$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+) should have (\d+) crystals$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^player (\d+) should have (\d+) crystal$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

