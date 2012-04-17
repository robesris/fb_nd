class Game < ActiveRecord::Base
  attr_accessible :board

  has_many :players
  belongs_to :active_player, :class_name => Player
  belongs_to :winner, :class_name => Player
  belongs_to :waiting_for, :class_name => Piece
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

  def move(args)
    col1 = args[:col1]
    row1 = args[:row1]
    args[:col] = args[:col2]
    args[:row] = args[:row2]
    self.board.space(col1, row1).piece.move(args)
  end

  def choose(args)
    return false unless self.waiting_for

    self.waiting_for.player_input(args)
  end

  def graveyard
    self.board.graveyard
  end

  def empty_graveyard
    self.board.empty_graveyard
  end
end
