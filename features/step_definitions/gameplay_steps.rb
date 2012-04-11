def irow(row)
  if row.is_a?(String)
    row[0] - 96
  else
    row
  end
end

Given /^an empty board$/ do
  @game = Game.new
  @game.save
  @game.player1.update_attributes(:game => @game)
  @game.player2.update_attributes(:game => @game)
  @player = [nil, { :pieces => {} }, { :pieces => {} }]
end

Given /^player (\d+) has a '(.*)' at '([a-g])(\d+)'$/ do |pnum, piece_name, row, col|
  piece = Kernel.const_get(piece_name).new
  piece.player = @game.playernum(pnum)
  if row.is_a?(String)
    row = row[0] - 96
  end
  puts "ROW: #{row} COL: #{col}"
  space = @game.board.space(row, col)
  space.piece = piece
  space.save
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
  player = @game.playernum(pnum.to_i)
  player.crystals = num
  player.save
end

Given /^the graveyard is empty$/ do
  @game.empty_graveyard
end

Given /^it is player (\d+)s turn$/ do |pnum|
  @game.active_player = pnum
end

When /^player (\d+) moves from '([a-g])(\d+)' to '([a-g])(\d+)'$/ do |pnum, row1, col1, row2, col2|
  if row1.is_a?(String)
    row1 = row1[0] - 96
  end
  if row2.is_a?(String)
    row2 = row2[0] - 96
  end
  @game.move(row1, col1, row2, col2)
  puts "AFTERMOVE: #{@game.player1.inspect}"
end

Then /^player (\d+)s '(.*)' should be in the graveyard$/ do |pnum, piece_name|
  piece = @game.playernum(pnum).pieces.where(:name => piece_name).first
  piece.space.should be_nil
  piece.row.should == nil
  piece.col.should == nil
  piece.in_graveyard?.should be_true
  puts Player.all.inspect
end

Then /^players (\d+)s '(.*)' should be at '([a-g])(\d+)'$/ do |pnum, piece_name, row, col|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.row.should == irow(row)
  piece.col.should == col.to_i
  puts Player.all.inspect
end

Then /^player (\d+) should have (\d+) crystals?$/ do |pnum, num|
  @game.playernum(pnum).crystals.should == num.to_i
end

