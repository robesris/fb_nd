def icol(col)
  if col.is_a?(String)
    col[0] - 96
  else
    col
  end
end

Given /^an empty board$/ do
  @game = Game.new
  @game.save
  @game.player1.update_attributes(:game => @game)
  @game.player2.update_attributes(:game => @game)
  @player = [nil, { :pieces => {} }, { :pieces => {} }]
end

Given /^player (\d+) has a '(.*)' at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  piece = Kernel.const_get(piece_name).new
  piece.player = @game.playernum(pnum)
  col = icol(col)
  space = @game.board.space(col, row)
  space.piece = piece
  space.save
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
  @game.save
end

When /^player (\d+) moves from '([a-g])(\d+)' to '([a-g])(\d+)'$/ do |pnum, col1, row1, col2, row2|
  col1 = icol(col1)
  col2 = icol(col2)
  puts "COLS: #{col1} #{col2}"
  @game.move(col1, row1, col2, row2)
end

When /^player (\d+) tries to move from '([a-g])(\d+)' to '([a-g])(\d+)'$/ do |pnum, col1, row1, col2, row2|
  steps %Q{
    When player #{pnum} moves from '#{col1}#{row1}' to '#{col2}#{row2}'
  }
end

Then /^player (\d+)s '(.*)' should be in the graveyard$/ do |pnum, piece_name|
  piece = @game.playernum(pnum).pieces.where(:name => piece_name).first
  piece.space.should be_nil
  piece.row.should == nil
  piece.col.should == nil
  piece.in_graveyard?.should be_true
end

Then /^player (\d+)s '(.*)' should be at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.col.should == icol(col)
  piece.row.should == row.to_i
end

Then /^player (\d+) should have (\d+) crystals?$/ do |pnum, num|
  @game.playernum(pnum).crystals.should == num.to_i
end

Then /^player (\d+)s '(.*)' should not be at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  (piece.col == icol(col) || piece.row == row).should be_false
end

Then /^it should be player (\d+)s turn$/ do |pnum|
  @game = Game.find(@game.id)
  @game.active_player.should == pnum.to_i
end

