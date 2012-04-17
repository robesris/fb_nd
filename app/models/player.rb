class Player < ActiveRecord::Base
  attr_accessible :crystals, :num, :game

  belongs_to :game
  has_many :pieces

  def add_crystals(num)
    self.crystals += num
    self.crystals = 60 if self.crystals > 60
    self.save
  end

  def opponent
    self.game.players.reject{ |p| p == self }.first
  end

  def choose(target)
    self.game.choose(:player => self, :target => target)
  end

  def lose_game
    self.opponent.win_game
  end

  def win_game
    self.game.update_attribute(:winner, self)
  end
end
