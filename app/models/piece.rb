class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type

  def move
    puts "moving"
    debugger
    puts "moved"
  end
end
