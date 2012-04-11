class Player < ActiveRecord::Base
  attr_accessible :crystals, :num, :game

  belongs_to :game
  has_many :pieces
end
