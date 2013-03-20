class Piece < ActiveRecord::Base
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
    debugger
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

  def grid
    self.flipped? ? self.side2 : self.side1
  end

  def move_to_keep
    space = self.player.keep.select{ |space| !space.occupied? }.first
    #self.update_attribute(:space, space)
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

  def can_reach?(to_space)
    # can't move to a space we're already on
    return false if !self.on_board? || to_space == self.space
  
    #Flip the movement grid around for player 2 (i.e. second player)

		#calculate the number of columns and rows the space is from current position
		col_move = to_space.col - self.space.col # Left: <0  Right: >0
		row_move = to_space.row - self.space.row # Up: >0  Down: <0

    #check if the piece's movement grid allows it to move DIRECTLY (i.e. 'jump') to the specified space 
		if can_move_directly? col_move, row_move
		  return true
		else #if the piece can't jump to the specified space, see if it can 'slide' there
      intervening_spaces = can_slide_to?(to_space)

      # check to see if we can or need to leap, and then decide if movement is possible or not
      return intervening_spaces && enough_leaps?(intervening_spaces)
		end
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

  # this is just here as I refactor its functionality out
  def oldmove(args = {})
    # moving can never be done after another action, so you can only move when there is no active piece
    return false unless this_player_active? && !any_piece_active?

    my_target_space = target_space(args)
    result = { :kill => [] }

    if self.can_reach?(my_target_space)
      # capture the occupying piece, if present
      try_to_capture(my_target_space, result) if my_target_space.occupied?

      self.space = my_target_space
      self.player.update_attribute(:active_piece, self)
      if self.save
        # pass turn after a successful move
        # actually, maybe better to leave auto-passing up to the stone pieces and flipped pieces with no invoke ability
        self.game.pass_turn if self.flipped? && !self.respond_to?(:invoke) 
        return result
      else
        return false
      end
    else
      return false
    end
  end

  def flip(pass = true)
    # The piece's player must be active, and if there is an active piece, 
    # it has to be this one (can't move one piece and flip another)
    return false unless this_player_active? && (is_active_piece? || no_piece_active?)

    flip_cost = self.val
    flip_cost = (flip_cost / 2.0).ceil if in_half_crystal_zone?
    return false if self.flipped? || my_player_crystals < flip_cost

    self.player.add_crystals(-flip_cost)
    self.update_attribute(:flipped, true)
    
    # in general, flipping will be the end of the turn
    self.game.pass_turn if pass

    true
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

  def calculate_col_dir(col_distance, row_distance)
    # +1 or -1
    col_distance / row_distance
  end

  def calculate_row_dir(row_distance, col_distance)
    # +1 or -1
    row_distance / col_distance
  end

  def calculate_dir_sym(col_dir, row_dir)
    col_dir_sym = col_dir > 0 ? 'r' : 'l'
    row_dir_sym = row_dir > 0 ? 'u' : 'd'
    dir_sym = "#{row_dir_sym}#{col_dir_sym}".to_sym
    leap_dir_sym = "leap_#{row_dir_sym}#{col_dir_sym}".to_sym
    dir_sym = leap_dir_sym if can_leap?(leap_dir_sym)

    dir_sym
  end

  def compass_has_dir?(dir_sym)
    my_adjusted_grid.include?(dir_sym)
  end

  def can_leap?(leap_dir_sym)
    my_adjusted_grid.include? leap_dir_sym
  end

  def calculate_leap_spaces_remaining(dir_sym)
    # Why not just true or false?  We may want to at some point add pieces that can jump over more than 2.
    dir_sym.to_s.include?('leap') ? 1 : 0
  end

  def enough_leaps?(intervening_spaces)
    leaps_remaining = calculate_leap_spaces_remaining(intervening_spaces[:dir_sym])

    intervening_spaces[:spaces].each do |space|
      if space.occupied?
        if leaps_remaining <= 0
          return false
        else
          leaps_remaining -= 1
        end
      end
    end
  end

  def can_move_directly?(col_move, row_move)
    col_move.abs <= Constants::MAX_COL_MOVE &&
		row_move.abs <= Constants::MAX_ROW_MOVE &&
		my_adjusted_grid[Constants::MOVEMENT_GRID_CENTER - (Constants::MOVEMENT_GRID_WIDTH * row_move) + col_move] != 0
  end

  def can_slide_to?(to_space)
    # almost all pieces need a straight line to the target - it must be in same row, col, or diagonal
    col_distance = calculate_distance(:col, to_space)
    row_distance = calculate_distance(:row, to_space)

    # We don't have to check if both are 0 because we already reject this case implicitly in can_reach 
    if col_distance.abs == 0 || row_distance.abs == 0
      return false unless result = check_orthogonal_direction(:col_distance => col_distance, 
                                                              :row_distance => row_distance,  
                                                              :to_space => to_space)
      dir_sym = result[:dir_sym]
      intervening_spaces = result[:spaces]
    elsif (col_dir = calculate_col_dir(col_distance, row_distance)) &&
          (row_dir = calculate_row_dir(row_distance, col_distance)) && 
          diagonal_move?(col_distance, row_distance)
      dir_sym = calculate_dir_sym(col_dir, row_dir)
      return false unless compass_has_dir?(dir_sym)
      intervening_spaces = calculate_diagonal_intervening_spaces(col_dir, row_dir, to_space)
    else
      # TODO: put in stuff to handle Ghora, Han, and leaping pieces
      return false
    end

    {:spaces => intervening_spaces,
     :dir_sym => dir_sym}
  end

  def dir_params_hash(normal, leap, gt, lt)
    { :normal => normal, 
      :leap => leap, 
      :gt_board_different_row_or_col => gt,
      :lt_board_different_row_or_col => lt
    }
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

  def any_piece_active?
    # the current active piece should probably be moved or at least accessible from the game model
    self.player.active_piece
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

  def my_reverse_grid
    self.grid.reverse
  end

  def my_adjusted_grid
    first_players_piece? ? self.grid : my_reverse_grid
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

  def diagonal_space?(to_space)
    (to_space.row - my_row).abs == (to_space.col - my_col).abs 
  end

  def calculate_intervening_col_or_row_spaces(row_or_col, to_space_col_or_row, row_or_col_dir)
      to_space_col_or_row * row_or_col_dir > row_or_col_dir &&
      row_or_col * row_or_col_dir < to_space_col_or_row
  end

  def calculate_diagonal_intervening_spaces(col_dir, row_dir, to_space) 
    game_board_spaces.select do |s|
      calculate_intervening_col_or_row_spaces(s.row, to_space.col, col_dir) && 
      calculate_intervening_col_or_row_spaces(s.row, to_space.row, row_dir) &&
      diagonal_space?(to_space)   
    end
  end

  def calculate_col_distance(to_space)
    (to_space.col - my_col) * (second_players_piece? ? -1 : 1)
  end

  def calculate_row_distance(to_space)
    (to_space.row - my_row) * (second_players_piece? ? -1 : 1)
  end
  
  def calculate_distance(row_or_col, to_space)
    row_or_col == :col ? calculate_col_distance(to_space) : calculate_row_distance(to_space)
  end

  def diagonal_move?(col_distance, row_distance)
    col_distance.abs == row_distance.abs
  end

  def calculate_v_or_h_direction_params(row_or_col_distance, row_1, row_2, dir_sym, leap_sym)
    dir_params_hash(dir_sym, leap_sym, row_1, row_2)
  end

  def calculate_vertical_direction_params(row_distance, to_row)
    if row_distance > 0
      dir_sym = :up
      leap_sym = :leap_up
      row_1 = to_row
      row_2 = my_row
    else
      dir_sym = :dn
      leap_sym = :leap_dn
      row_1 = my_row
      row_2 = to_row
    end

    { :same => :col, 
      :different => :row,
      :my_same_row_or_col => my_col 
    }.merge(calculate_v_or_h_direction_params(row_distance, 
                                              row_1,
                                              row_2, 
                                              dir_sym, 
                                              leap_sym))
  end

  def calculate_horizontal_direction_params(col_distance, to_col)
    if col_distance > 0
      dir_sym = :rt
      leap_sym = :leap_rt
      col_1 = to_col
      col_2 = my_col
    else
      dir_sym = :lt
      leap_sym = :leap_lt
      col_1 = my_col
      col_2 = to_col
    end

    { :same => :row, 
      :different => :col,
      :my_same_row_or_col => my_row 
    }.merge(calculate_v_or_h_direction_params(col_distance, 
                                              col_1,
                                              col_2, 
                                              dir_sym, 
                                              leap_sym))
  end
  
  def calculate_direction_params(move_params)
    col_distance = move_params[:col_distance]
    row_distance = move_params[:row_distance]
    to_space = move_params[:to_space]

    if col_distance.abs == 0    # same col: move in direction of row_distance's sign
      calculate_vertical_direction_params(row_distance, to_space.row)
    elsif row_distance.abs == 0 # same row: move in direction of col_distance's sign
      calculate_horizontal_direction_params(col_distance, to_space.col)
    end
  end

  def check_orthogonal_direction(move_params)
    direction_params = calculate_direction_params(move_params)
    
    normal = direction_params[:normal]
    leap = direction_params[:leap]
    my_same_row_or_col = direction_params[:my_same_row_or_col]
    gt_board_different_row_or_col = direction_params[:gt_board_different_row_or_col]
    lt_board_different_row_or_col = direction_params[:lt_board_different_row_or_col]
    same = direction_params[:same]
  
    return false unless self.grid.include?(normal) || self.grid.include?(leap)
    dir_sym = self.grid.include?(leap) ? leap : normal

    spaces = self.board.spaces.select do |s| 
      board_same_row_or_col = (same == :col ? s.col : s.row)
      board_different_row_or_col = (same == :col ? s.row : s.col)

      board_same_row_or_col == my_same_row_or_col && 
      board_different_row_or_col > lt_board_different_row_or_col && 
      board_different_row_or_col < gt_board_different_row_or_col
    end

    { :spaces => spaces, :dir_sym => dir_sym }
  end
end
