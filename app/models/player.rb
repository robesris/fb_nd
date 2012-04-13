class Player < ActiveRecord::Base
  attr_accessible :crystals, :num, :game

  belongs_to :game
  has_many :pieces

  def add_crystals(num)
    self.crystals += num
    self.crystals = 60 if self.crystals > 60
    self.save
  end
end
