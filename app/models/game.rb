class Game < ActiveRecord::Base
  attr_accessible :board, :active_player, :phase

  has_many :players
  belongs_to :active_player, :class_name => Player
  belongs_to :winner, :class_name => Player
  belongs_to :waiting_for, :class_name => Piece
  has_one :board
  has_many :events

  before_create :build_game
  
  def self.generate_secret
    rand(36**20).to_s(36)
  end

  def default_setup
    1.upto(7) do |n|
      BlackStone.create(:player => self.player1, :space => self.board.spaces.where(:col => n, :row => 2).first)
      BlackStone.create(:player => self.player2, :space => self.board.spaces.where(:col => n, :row => 6).first)
    end

    RedStone.create(:player => self.player1, :space => self.board.spaces.where(:col => 2, :row => 1).first)
    RedStone.create(:player => self.player1, :space => self.board.spaces.where(:col => 6, :row => 1).first)
    RedStone.create(:player => self.player2, :space => self.board.spaces.where(:col => 2, :row => 7).first)
    RedStone.create(:player => self.player2, :space => self.board.spaces.where(:col => 6, :row => 7).first)
  end

  def start_game
    return false unless self.phase == 'setup' && self.player1.ready? && self.player2.ready?

    self.update_attributes(:active_player => self.active_player || self.player1,
                           :phase => 'play')
  end

  def player1
    self.players.where(:num => 1).first
  end

  def player2
    self.players.where(:num => 2).first
  end

  def pieces
    self.player1.pieces + self.player2.pieces
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

  def wait_for(piece)
    self.update_attribute(:waiting_for, piece)
  end

  def move(args)
    col1 = args[:col1]
    row1 = args[:row1]
    args[:col] = args[:col2]
    args[:row] = args[:row2]
    self.board.space(col1, row1).piece.move(args)
  end

  def pass_turn
    self.update_attribute(:active_player, self.players.reject{ |p| p.num == self.active_player.num }.first)
    self.players.each do |player|
      player.update_attribute(:active_piece, nil)
    end
    self.active_player.update_attribute(:in_check_this_turn, false)
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

  def add_event(params)
    self.events << Event.create(params)
  end


  private

  def build_game
    self.code = Game.generate_secret
    self.players << Player.create(:num => 1)
    self.players << Player.create(:num => 2)
    
    self.board = Board.create(nil)
    self.phase = "setup"
  end
end
