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

  def room_in_keep?
    self.keep.select{ |space| !space.occupied? }.present?
  end

  def empty_keep?
    self.keep.select{ |space| space.piece }.empty?
  end

  def empty_keep_space
    self.keep.select{ |space| !(space.piece) }.first
  end

  def keep_full?
    !self.room_in_keep?
  end

  def draft(piece_name, space)
    return false if !space || space.occupied?
    piece_class = Kernel.const_get(piece_name)
    if piece_class.superclass == Piece::Nav &&
       self.game.phase == 'setup' &&
       !self.nav
      return false unless space == self.game.board.nav_space(:player => self)
      #piece = piece_class.create(:space => self.game.board.nav_space(:player => self))
      piece = piece_class.create(:space => space)
      self.pieces << piece
      return piece
    elsif self.game.phase == 'setup' &&
       self.room_in_keep? &&
       self.pieces.where(:name => piece_name).size < 2 &&
       piece = piece_class.create(:space => space)
      self.pieces << piece
      #piece.move_to_keep 
      return piece
    end  

    false
  end

  def move(piece, space)
    if self.pieces.include?(piece)
      return piece.move({:space => space, :pass => false})
    else
      return false
    end
  end

  def get_ready
    self.ready = self.nav && self.keep_full?
    self.save
  end

  def start_game
    self.game.start_game
  end

  def add_crystals(num)
    self.crystals += num
    self.crystals = 60 if self.crystals > 60
    self.save
  end

  def nav
    self.pieces.select{ |p| p.kind_of?(Piece::Nav) }.first
  end

  def opponent
    self.game.players.reject{ |p| p == self }.first
  end

  def choose(target)
    self.game.choose(:player => self, :target => target)
  end

  def in_check?
    opponent_pieces = self.opponent.pieces
    can_capture = opponent_pieces.select{ |p| p.can_reach?(self.nav.space) }.present?
    can_capture
  end

  def lose_game
    self.opponent.win_game
  end

  def win_game
    self.game.update_attribute(:winner, self)
  end
end
