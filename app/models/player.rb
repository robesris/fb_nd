class Player < ActiveRecord::Base
  attr_accessible :crystals, :num, :game, :keep

  belongs_to :game
  belongs_to :active_piece, :class_name => Piece
  has_many :pieces
  has_many :keep, :class_name => Space

  before_create :build_player

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

  def owns_piece?(piece)
    self.pieces.include?(piece)
  end

  def is_active?
    self.game.active_player == self
  end

  def summon(piece, space)
    if self.pieces.include?(piece)
      return piece.summon({:space => space, :pass => true}) # summoning ends turn unless the result of an ability
    else
      return false
    end
  end

  def activate_piece(piece)
    self.active_piece = piece
    self.save
  end

  def move_piece(piece, space, pass = false)
    #self.owns_piece?(piece) && piece.move({:space => space, :pass => pass})
    self.owns_piece?(piece) && move = Move.new(:player => piece.player, :piece => piece, :space => space, :pass => pass)
    move && move.save
    move
  end

  def flip(piece)
    if self.pieces.include?(piece)
      piece.flip
    else
      false
    end
  end

  def pass_turn
    # don't forget you have to do SOMETHING on your turn before passing!
    #debugger
    self.game.pass_turn if self.is_active? && self.active_piece && !self.game.waiting_for
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

  def check_events
    events = []
    unless self.checking_for_events? || self.game.phase == 'setup'
      ActiveRecord::Base.transaction do
        begin
          self.update_attribute(:checking_for_events, true)
          events = self.game.events.where(:player_num => self.num) #.reject{ |e| e.action == 'move' }
          events.each { |e| e.destroy }
          self.update_attribute(:checking_for_events, false)
        rescue ActiveRecord::Rollback
          render :json => []  # return nothing if the transaction is rolled back
        end
      end
    end

    events = events.map{ |event| { :action => event.action, :piece_unique_name => event.piece && event.piece.unique_name, :to => event.to, :options => event.options } }
    events << { :action => 'active_player', :options => { :active_player_num => self.game.active_player.num } } if self.game.active_player && self.game.active_player.num
    events
  end

  private

  def build_player
    self.crystals = 0
    1.upto(7) do |col|
      self.keep << Space.create(:row => self.num == 1 ? -2 : 9, :col => col)
    end
  end
end


