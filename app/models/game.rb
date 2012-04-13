class Game < ActiveRecord::Base
  attr_accessible :board

  has_many :players
  has_one :board
  
  def initialize(params = nil, options = {})
    super(params)
    self.players << Player.create(:num => 1, :crystals => 0)
    self.players << Player.create(:num => 2, :crystals => 0)

    self.board = Board.create(nil)
  end

  def player1
    self.players.where(:num => 1).first
  end

  def player2
    self.players.where(:num => 2).first
  end

  def playernum(num)
    num = num.to_i
    if num == 1
      player1
    elsif num == 2
      player2
    else
      nil
    end
  end

  def move(col1, row1, col2, row2)
    self.board.space(col1, row1).piece.move(col2, row2)
  end

  def graveyard
    self.board.graveyard
  end

  def empty_graveyard
    self.board.empty_graveyard
  end
end
