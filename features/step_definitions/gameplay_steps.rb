def icol(col)
  if col.is_a?(String)
    col.ord - 96
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

Given /^player (\d+) has an? '(.*)' at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  piece = Kernel.const_get(piece_name).new
  piece.player = @game.playernum(pnum)
  col = icol(col)
  space = @game.board.space(col, row)
  space.piece = piece
  space.save
  @game.playernum(pnum).pieces << piece
end

Given /^player (\d+) has a '(.*)' in the graveyard$/ do |pnum, piece_name|
  piece = Kernel.const_get(piece_name).new
  piece.player = @game.playernum(pnum)
  piece.space = nil
  piece.in_graveyard = true
  piece.save
  @game.playernum(pnum).pieces << piece 
end

Given /^player (\d+)s '(.*)' is flipped$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
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
  pnum = pnum.to_i
  @game.active_player = @game.players.select { |p| p.num == pnum }.first
  @game.save
end

When /^player (\d+) moves from '([a-g])(\d+)' to '([a-g])(\d+)'(| and does not pass the turn)$/ do |pnum, col1, row1, col2, row2, pass|
  col1 = icol(col1)
  col2 = icol(col2)
  #@game.move({ :col1 => col1, :row1 => row1, :col2 => col2, :row2 => row2, :pass => pass.blank? ? true : false })
  player = @game.playernum(pnum)
  piece = @game.board.space(col1, row1).piece
  space = @game.board.space(col2, row2)
  pass = pass.blank?

  player.move_piece(piece, space, pass)

  # pass the turn unless we specify otherwise
  #@game.playernum(pnum).pass_turn if pass.blank?
end

When /^player (\d+) tries to move from '([a-g])(\d+)' to '([a-g])(\d+)'(| and does not pass the turn)$/ do |pnum, col1, row1, col2, row2, pass|
  steps %Q{
    When player #{pnum} moves from '#{col1}#{row1}' to '#{col2}#{row2}'#{pass}
  }
end

Then /^player (\d+)s '(.*)' should be in the graveyard$/ do |pnum, piece_name|
  piece = @game.playernum(pnum).pieces.where(:name => piece_name).first
  piece.space.should be_nil
  piece.row.should == nil
  piece.col.should == nil
  piece.in_graveyard?.should be true
end

Then /^player (\d+)s '(.*)' should not be in the graveyard$/ do |pnum, piece_name|
  piece = @game.playernum(pnum).pieces.where(:name => piece_name).first
  piece.in_graveyard?.should be false
end

Then /^player (\d+)s '(.*)' should be at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.col.should == icol(col)
  piece.row.should == row.to_i
end

Then /^player (\d+) should have an? '(.*)' at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  steps %Q{
    Then player #{pnum}s '#{piece_name}' should be at '#{col}#{row}'
  }
end

Then /^player (\d+) should have (\d+) crystals?$/ do |pnum, num|
  @game.playernum(pnum).crystals.should == num.to_i
end

Then /^player (\d+)s '(.*)' should not be at '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.space.should_not == @game.board.space(icol(col), row.to_i)
end

Then /^it should (?:|still )be player (\d+)s turn$/ do |pnum|
  @game = Game.find(@game.id)
  @game.active_player.num.should == pnum.to_i
end

When /^player (\d+) (?:flips|tries to flip) '(.*)'$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.flip
end

Then /^player (\d+)s '(.*)' should be flipped$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.flipped?.should be true
end

Then /^player (\d+)s '(.*)' should not be flipped$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.flipped?.should be false
end

Then /^player (\d+) should win the game$/ do |pnum|
  @game = Game.find(@game.id)
  @game.winner.num.should == pnum.to_i
end

When /^player (\d+) chooses player (\d+)s '(.*)'$/ do |pnum, target_pnum, piece_name|
  @game.playernum(pnum).choose(@game.playernum(target_pnum).pieces.where(:name => piece_name).first)
end

When /^player (\d+) chooses '([a-g])(\d+)'$/ do |pnum, target_col, target_row|
  @game.playernum(pnum).choose(@game.board.spaces.where(:col => icol(target_col), :row => target_row.to_i).first)
end

When /^player (\d+) chooses 'crystals'$/ do |pnum|
  player = @game.playernum(pnum)
  player.choose('crystals')
end


Given /^player (\d+) has an? '(.*)' in his keep$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  empty_keep_space = player.keep.select{ |space| !space.occupied? }.first
  piece = Kernel.const_get(piece_name).create(:player => @game.playernum(pnum), :space => empty_keep_space)
end

When /^player (\d+) (?:tries to summon|summons) '(.*)' to '([a-g])(\d+)'$/ do |pnum, piece_name, col, row|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.summon({:col => icol(col), :row => row.to_i})
end

Then /^player (\d+)s '(.*)' should be in his keep$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.in_keep?.should be true
end

Then /^player (\d+)s '(.*)' should not be in his keep$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.in_keep?.should be false
end

Then /^the game should be in progress$/ do
  @game.winner.should be_nil
end

When /^player (\d+) tries to Goal Over$/ do |pnum|
  @game.playernum(pnum).nav.goal_over
end

When /^player (\d+) Lines Over with his '(.*)'$/ do |pnum, piece_name|
  player = @game.playernum(pnum)
  piece = player.pieces.where(:name => piece_name).first
  piece.line_over
end

When /^player (\d+) Goals Over$/ do |pnum|
  steps %Q{
    When player #{pnum} tries to Goal Over
  }
end

Then /^player (\d+) should be in check$/ do |pnum|
  @game.playernum(pnum).in_check?.should be true
end

Then /^player (\d+) should not be in check$/ do |pnum|
  @game.playernum(pnum).in_check?.should be false
end

When /^player (\d+) passes the turn$/ do |pnum|
  @game.pass_turn
end

When /^player (\d+) cancels '(.*)'$/ do |pnum, piece_name|
  @game.playernum(pnum).pieces.where(:name => piece_name).first.cancel
end

