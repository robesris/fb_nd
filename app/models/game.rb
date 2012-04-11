class Game < ActiveRecord::Base
  attr_accessible :player1, :player2

  belongs_to :player1, :class_name => Player
  belongs_to :player2, :class_name => Player
  has_one :board

  def initialize(params = nil, options = {})
    super(params)
    puts "PARAMS: " + params.inspect
    self.board = Board.create(nil)
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

  def move(row1, col1, row2, col2)
    self.board.space(row1, col1).piece.move(row2, col2)
  end

  def graveyard
    self.board.graveyard
  end

  def empty_graveyard
    self.board.empty_graveyard
  end
end
