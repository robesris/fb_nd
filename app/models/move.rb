class Move < ActiveRecord::Base
  attr_accessible :capture_allowed, :earn_crystals, :pass, :piece_id, :player_id, :space_id
end
