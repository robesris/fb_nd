class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type, :player, :space, :unique_name, :in_graveyard
  
  belongs_to :player
  has_one :board, :through => :space
  has_one :game, :through => :player
  has_one :space

  #validates_uniqueness_of :unique_name, :scope => :game_id

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

  MOVEMENT_GRID_WIDTH = 5
	MOVEMENT_GRID_HEIGHT = 5
	MAX_COL_MOVE = (MOVEMENT_GRID_WIDTH - 1) / 2 # => 2
	MAX_ROW_MOVE = (MOVEMENT_GRID_HEIGHT - 1) / 2 # => 2
	MOVEMENT_GRID_CENTER = MOVEMENT_GRID_WIDTH * MAX_ROW_MOVE + MAX_COL_MOVE # => 12

  BLACK							= [ 0, 0, 0, 0, 0,
												0, 0, 1, 0, 0,
												0, 0, 0, 0, 0,
												0, 0, 0, 0, 0,
												0, 0, 0, 0, 0 ]

	RED								= [ 0, 0, 0, 0, 0,
												0, 1, 1, 1, 0,
												0, 0, 0, 0, 0,
												0, 0, 0, 0, 0,
												0, 0, 0, 0, 0 ]

  GOLD							= [ 0, 0, 0, 0, 0,
												0, 1, 1, 1, 0,
												0, 1, 0, 1, 0,
												0, 0, 1, 0, 0,
												0, 0, 0, 0, 0 ]

  KING							= [ 0, 0, 0, 0, 0,
												0, 1, 1, 1, 0,
												0, 1, 0, 1, 0,
												0, 1, 1, 1, 0,
												0, 0, 0, 0, 0 ]

  QUEEN							= [ 0, 0, 0, 0, 0,
												0, :ul, :up, :ur, 0,
												0, :lt, 0, :rt, 0,
												0, :dl, :dn, :dr, 0,
												0, 0, 0, 0, 0 ]

  ROOKLIKE					= [ 0, 0, 1, 0, 0,
												0, 0, 1, 0, 0,
												1, 1, 0, 1, 1,
												0, 0, 1, 0, 0,
												0, 0, 1, 0, 0 ]

	BISHOPLIKE				= [ 1, 0, 0, 0, 1,
												0, 1, 0, 1, 0,
												0, 0, 0, 0, 0,
												0, 1, 0, 1, 0,
												1, 0, 0, 0, 1 ]
  
  def initialize(params = nil, options = {})
    super(params)
    #raise params.inspect
    #game = 
    self.name = self.class.to_s

    # realistically, pieces should never be created so fast that these ids would ever be the same
    # forget this for now.
    #while self.unique_name.nil? || (game.pieces.present? && game.pieces.select{ |piece| piece.unique_name == self.unique_name }.present?)
      self.unique_name = self.name.downcase + "_" + Time.now.to_f.to_s.sub('.', '')
    #end
  end

  def grid
    self.flipped? ? self.side2 : self.side1
  end

  def move_to_keep
    space = self.player.keep.select{ |space| !space.occupied? }.first
    self.update_attribute(:space, space)
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
    return false if self.game.active_player != self.player || self.player.active_piece  # moving can never be done after another action, so you can only move when there is no active piece

    space = if args[:space].kind_of?(Space)
                     args[:space]
                   else
                     self.game.board.space(args[:col], args[:row])
                   end
    pass = args[:pass].present? ? args[:pass] : true
    
    if self.guard?
      if self.in_keep? && space.adjacent_to_nav?(self.player) && !space.occupied?
        self.update_attribute(:space, space)
        self.game.pass_turn if pass
      else
        return false
      end
    else
      if self.in_keep? && space.summon_space == self.player.num && !space.occupied?
        self.update_attribute(:space, space)
        self.game.pass_turn if pass
      else
        return false
      end
    end
  end

  def move(args = {})
    #game = self.game
    
    return false if game.active_player != self.player || self.player.active_piece  # moving can never be done after another action, so you can only move when there is no active piece

    target_space = if args[:space].kind_of?(Space)
                     args[:space]
                   else
                     self.board.space(args[:col], args[:row])
                   end
    pass = args[:pass]

    result = { :kill => [] }
    if self.can_reach?(target_space)
      # capture the occupying piece, if present
      if target_space.occupied?
        # can't capture your own piece
        if target_space.piece.player == self.player
          return false
        else
          self.player.add_crystals(target_space.piece.val)
          result[:kill] << target_space.piece
          target_space.piece.die
        end
      end
      self.space = target_space
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
    return false unless this_player_active? && is_active_piece?
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

  def calculate_col_dir(col_distance, row_distance)
    # +1 or -1
    col_distance / row_distance
  end

  def calculate_row_dir(row_distance, col_distance)
    # +1 or -1
    row_distance / col_distance
  end

  def calculate_dir_sym(col_distance, row_distance, col_dir, row_dir)
    col_dir_sym = col_dir > 0 ? 'r' : 'l'
    row_dir_sym = row_dir > 0 ? 'u' : 'd'
    dir_sym = "#{row_dir_sym}#{col_dir_sym}".to_sym
    leap_dir_sym = "leap_#{row_dir_sym}#{col_dir_sym}".to_sym
    dir_sym = leap_dir_sym if self.can_leap?(leap_dir_sym)
  end

  def compass_has_dir?(dir_sym)
    self.my_adjusted_grid.include?(dir_sym)
  end

  def can_leap?(leap_dir_sym)
    self.my_adjusted_grid.include? leap_dir_sym
  end

  def calculate_leap_spaces_remaining(dir_sym)
    # Why not just true or false?  We may want to at some point add pieces that can jump over more than 2.
    dir_sym.to_s.include?('leap') ? 1 : 0
  end

  def enough_leaps?(intervening_spaces)
    leaps_remaining = calculate_leap_spaces_remaining

    intervening_spaces.each do |space|
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
    col_move.abs <= MAX_COL_MOVE &&
		row_move.abs <= MAX_ROW_MOVE &&
		my_adjusted_grid[MOVEMENT_GRID_CENTER - (MOVEMENT_GRID_WIDTH * row_move) + col_move] != 0
  end

  def can_slide_to?(to_space)
    # almost all pieces need a straight line to the target - it must be in same row, col, or diagonal
    col_distance = calculate_distance(:col, to_space)
    row_distance = calculate_distance(:row, to_space)

    # We don't have to check if both are 0 because we already reject this case at the start of the method
    if col_distance.abs == 0 || row_distance.abs == 0
      return false unless intervening_spaces = check_orthogonal_direction(:col_distance => col_distance, 
                                                                          :row_distance => row_distance, 
                                                                          :to_space => to_space)
    elsif col_dir = calculate_col_dir && row_dir = calculate_row_dir && diagonal_move?(col_distance, row_distance, col_dir, row_dir)
      return false unless self.compass_has_dir?(calculate_dir_sym(col_distance, row_distance))
      intervening_spaces = calculate_intervening_spaces(to_space)
    else
      # TODO: put in stuff to handle Ghora, Han, and leaping pieces
      return false
    end

    intervening_spaces
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
    self.player.active_piece && self.player.active_piece != self
  end
  
  def this_player_active?
    active_player == self.player
  end

  def in_half_crystal_zone?
     self.space.half_crystal?
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

  def game_board
    self.game_board
  end

  def game_board_spaces
    game_board.spaces
  end

  def calculate_intervening_spaces(to_space, leap = false)
    board_spaces.each do |s|
      s.col * col_dir > my_col && s.col * col_dir < to_space.col &&    # spaces in intervening cols...
      s.row * row_dir > my_row && s.row * row_dir < to_space.row &&    # and intervening rows...
      (s.row - my_row).abs == (s.col - my_col).abs                     # that are an equal number of row and cols away
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

  def calculate_direction_params(move_params)
    col_distance = move_params[:col_distance]
    row_distance = move_params[:row_distance]
    to_space = move_params[:to_space]

    if col_distance.abs == 0    # same col: move in direction of row_distance's sign
      direction_params = { :same => :col, 
                           :different => :row,
                           :my_same_row_or_col => my_col }
      if row_distance > 0  # moving up
        direction_params.merge!(dir_params_hash(:up, :leap_up, to_space.row, my_row))                                     
      else                 # moving down
        direction_params.merge!(dir_params_hash(:dn, :leap_dn, my_row, to_space.row))
      end
    elsif row_distance.abs == 0 # same row: move in direction of col_distance's sign
      direction_params = { :same => :row, 
                           :different => :col,
                           :my_same_row_or_col => my_row }
      if col_distance > 0  # moving right 
        direction_params.merge!(dir_params_hash(:rt, :leap_rt, to_space.col, my_col))
      else                 # moving left
        direction_params.merge!(dir_params_hash(:lt, :leap_lt, my_col, to_space.col))
      end
    end

    direction_params
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

    self.board.spaces.select do |s| 
      board_same_row_or_col = (same == :col ? s.col : s.row)
      board_different_row_or_col = (same == :col ? s.row : s.col)

      board_same_row_or_col == my_same_row_or_col && 
      board_different_row_or_col > lt_board_different_row_or_col && 
      board_different_row_or_col < gt_board_different_row_or_col
    end
  end
end
