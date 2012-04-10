class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type
end
