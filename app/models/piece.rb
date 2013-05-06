class Piece < ActiveRecord::Base
  require File.dirname(__FILE__) + "/piece/lib/constants.rb"
  extend ActiveModel::Callbacks

  attr_accessible :col, :flipped, :name, :player_id, :row, :type, :player, :space, :unique_name, :in_graveyard

  belongs_to :player
  has_one :board, :through => :space
  has_one :game, :through => :player
  has_one :space
  has_many :moves

  #validates_uniqueness_of :unique_name, :scope => :game_id

  before_create :set_names

  def self.all_piece_klasses
    klasses = []
    Dir[Rails.root.join('app/models/piece/*.rb').to_s].each do |filename|
      klass = File.basename(filename).sub(/.rb$/, '').camelize
      unless klass == 'Nav' || klass == 'Stone'
        klass = klass.constantize
        klasses << klass
        #next unless klass.ancestors.include?(ActiveRecord::Base)
        # do something with klass
      end
    end
    klasses
  end

  def self.is_stone?
    false
  end

  def grid
    self.flipped? ? self.side2 : self.side1
  end

  def move_to_keep
    space = self.player.keep.select{ |space| !space.occupied? }.first
    self.space == space && self.save
  end

  def guard?
    false
  end

  def row
    self.space && self.space.row
  end

  def col
    self.space && self.space.col
  end

  def in_keep?
    self.player.keep.include?(self.space)
  end

  def on_board?
    #self.board.spaces.include?(self.space) && !self.in_graveyard?
    !self.in_graveyard? && !self.in_keep?
  end

  def summon(args = {})
    target_space = args[:space].kind_of?(Space) ? args[:space] : game_board_space(args[:col], args[:row])
    pass = args[:pass].present? ? args[:pass] : true
    if self.guard?
      guard_summon!(target_space, pass)
    else
      if self.in_keep? && target_space.summon_space == self.player.num && !target_space.occupied?
        self.update_attribute(:space, target_space)
        self.game.pass_turn if pass
      else
        return false
      end
    end
  end

  def move_to(space, pass = true)
    self.space = space
    self.save
    auto_pass if pass
  end

  # 'capture' is already taken
  def kapture(target_piece)
    award_crystals(target_piece.val)
    target_piece.die
  end

  def flip(pass = true)
    # The piece's player must be active, and if there is an active piece,
    # it has to be this one (can't move one piece and flip another)
    return false unless this_player_active? && (is_active_piece? || no_piece_active?)

    flip_cost = self.val
    flip_cost = (flip_cost / 2.0).ceil if in_half_crystal_zone?
    return { :status => 'failure', :message => "Can't flip that piece!" } if self.flipped? || my_player_crystals < flip_cost

    self.player.add_crystals(-flip_cost)
    self.update_attribute(:flipped, true)

    # in general, flipping will be the end of the turn
    self.game.pass_turn if pass

    result = { :status => 'success', :p1_crystals => game.player1.crystals, :p2_crystals => game.player2.crystals, :prompts => piece.current_prompts }

    game.add_event(
      :player_num => player.opponent.num,
      :action => 'flip',
      :piece => piece,
      :options => result
    )
  end

  def unflip(reimburse = true)  # used when cancelling
    if reimburse
      flip_cost = self.val
      flip_cost = (flip_cost / 2.0).ceil if self.space.half_crystal?
      self.player.add_crystals(flip_cost)
    end

    self.flipped = false
    self.save
  end

  def player_input(choosing_player)
    # Can only make choices for your own pieces
    choosing_player == self.player && self.waiting_state.present?
  end

  def die
    self.in_graveyard = true
    self.space = nil
    self.save
  end

  def in_last_row?
    self.player.num == 1 ? self.row == 7 : self.row == 1
  end

  def cancel
    false
  end

  def is_creature?
    true
  end

  def prompts
    nil
  end

  def waiting?
    self.waiting_state.present?
  end

  def current_prompts
    self.waiting? && self.prompts
  end

  private

  def set_names(params = nil, options = {})
    self.name = self.class.to_s

    # realistically, pieces should never be created so fast that these ids would ever be the same
    # forget this for now.
    #while self.unique_name.nil? || (game.pieces.present? && game.pieces.select{ |piece| piece.unique_name == self.unique_name }.present?)
      self.unique_name = self.name.downcase + "_" + Time.now.to_f.to_s.sub('.', '')
    #end
  end

  def auto_pass
    self.game.pass_turn
  end

  def active_player
    self.game.active_player
  end

  def my_player_num
    self.player.num
  end

  def my_player_crystals
    self.player.crystals
  end

  def first_players_piece?
    my_player_num == 1
  end

  def second_players_piece?
    my_player_num == 2
  end

  def is_active_piece?
    self.player.active_piece && self.player.active_piece == self
  end

  def no_piece_active?
    !any_piece_active?
  end

  def this_player_active?
    active_player == self.player
  end

  def award_crystals(num, player = self.player)
    player.add_crystals(num)
  end

  def change_space_to(target_space)
    self.update_attribute(:space, target_space)
  end

  # Might seem strange to have this in the Piece model
  # Might want to have something less direct, just alert player or
  # game that move is done.
  def pass_turn
    self.game.pass_turn
  end

  def guard_summon!(target_space, pass)
    if self.in_keep? && target_space.adjacent_to_nav?(self.player) && !target_space.occupied?
      change_space_to(target_space)
      pass_turn if pass
    else
      return false
    end
  end

  def in_half_crystal_zone?
     self.space.half_crystal?
  end

  def target_space(args)
    if args[:space].kind_of?(Space)
     args[:space]
   else
     self.board.space(args[:col], args[:row])
   end
  end

  # This 'result' seems unnecessary and is distinct from the other 'result'
  # (which should be made into an object)
  def try_to_capture(target_space, result)
    # can't capture your own piece
    if target_space.piece.player == self.player
      return false
    #else
     # award_crystals(target_space.piece.val)
      #result[:kill] << target_space.piece
      #target_space.piece.die
    end
  end

  def my_col
    self.space.col
  end

  def my_row
    self.space.row
  end

  def game_board_space(col, row)
    self.game.board.space(col, row)
  end

  def game_board
    self.game.board
  end

  def game_board_spaces
    game_board.spaces
  end
end
