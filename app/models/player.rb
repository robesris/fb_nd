class Player < ActiveRecord::Base
  attr_accessible :crystals, :num

  has_one :game
  has_many :pieces
end
