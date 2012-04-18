class Player < ActiveRecord::Base
  attr_accessible :crystals, :num, :game, :keep

  belongs_to :game
  belongs_to :active_piece, :class_name => Piece
  has_many :pieces
  has_many :keep, :class_name => Space

  def initialize(args = nil, options = {})
    super(args, options)
    1.upto(7) do |col|
      self.keep << Space.create(:row => args[:num] == 1 ? -2 : 9, :col => col)
    end
  end

  def add_crystals(num)
    self.crystals += num
    self.crystals = 60 if self.crystals > 60
    self.save
  end

  def nav
    self.pieces.select{ |p| p.kind_of?(Piece::Nav) }.first
  end

  def empty_keep?
    self.keep.select{ |space| space.piece }.empty?
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
