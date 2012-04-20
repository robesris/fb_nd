class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type, :player, :space
  
  belongs_to :player
  has_one :board, :through => :space
  has_one :game, :through => :player
  has_one :space

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
    self.name = self.class.to_s
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
    return false if to_space == self.space
  
    #Flip the movement grid around for player 2 (i.e. second player)
		grid = self.player.num == 1 ? self.grid : self.grid.reverse

		#calculate the number of columns and rows the space is from current position
		col_move = to_space.col - self.space.col # Left: <0  Right: >0
		row_move = to_space.row - self.space.row # Up: >0  Down: <0

    #check if the piece's movement grid allows it to move DIRECTLY (i.e. 'jump') to the specified space 
		if col_move.abs <= MAX_COL_MOVE &&
			 row_move.abs <= MAX_ROW_MOVE &&
			 grid[MOVEMENT_GRID_CENTER - (MOVEMENT_GRID_WIDTH * row_move) + col_move] != 0
		  return true
		else #if the piece can't jump to the specified space, see if it can 'slide' there
			# almost all pieces need a straight line to the target - it must be in same row, col, or diagonal

      my_col = self.space.col
      my_row = self.space.row
      col_distance = to_space.col - self.space.col
      row_distance = to_space.row - self.space.row
      if self.player.num == 2
        col_distance *= -1
        row_distance *= -1
      end
      intervening_spaces = nil
      dir_sym = nil

      # We don't have to check if both are 0 because we already reject this case at the start of the method
      if col_distance.abs == 0    # same col: move in direction of row_distance's sign
        if row_distance > 0  # moving up
          return false unless self.grid.include?(:up) || self.grid.include?(:leap_up)
          dir_sym = self.grid.include?(:leap_up) ? :leap_up : :up
          intervening_spaces = self.board.spaces.select{ |s| s.col == my_col && s.row > my_row && s.row < to_space.row}
        else                 # moving down
          return false unless self.grid.include?(:dn) || self.grid.include?(:leap_dn)
          dir_sym = self.grid.include?(:leap_dn) ? :leap_dn : :dn
          intervening_spaces = self.board.spaces.select{ |s| s.col == my_col && s.row < my_row && s.row > to_space.row}
        end
      elsif row_distance.abs == 0 # same row: move in direction of col_distance's sign
        if col_distance > 0  # moving right 
          return false unless self.grid.include?(:rt) || self.grid.include?(:leap_rt)
          dir_sym = self.grid.include?(:leap_rt) ? :leap_rt : :rt
          intervening_spaces = self.board.spaces.select{ |s| s.row == my_row && s.col > my_col && s.col < to_space.col}
        else                 # moving left
          return false unless self.grid.include?(:lt) || self.grid.include?(:leap_lt)
          dir_sym = self.grid.include?(:leap_lt) ? :leap_lt : :lt
          intervening_spaces = self.board.spaces.select{ |s| s.row == my_row && s.col < my_col && s.col > to_space.col}
        end
      elsif col_distance.abs == row_distance.abs # diagonal line
        col_dir = col_distance / col_distance   # +1 or -1
        row_dir = row_distance / row_distance   # +1 or -1
        col_dir_sym = col_dir > 0 ? 'r' : 'l'
        row_dir_sym = row_dir > 0 ? 'u' : 'd'
        dir_sym = "#{row_dir_sym}#{col_dir_sym}".to_sym
        leap_dir_sym = "leap_#{row_dir_sym}#{col_dir_sym}".to_sym
        dir_sym = leap_dir_sym if self.grid.include?(leap_dir_sym)
        return false unless self.grid.include?(dir_sym)
        intervening_spaces = self.game.board.spaces.select do |s|
          s.col * col_dir > my_col && s.col * col_dir < to_space.col &&    # spaces in intervening cols...
          s.row * row_dir > my_row && s.row * row_dir < to_space.row &&    # and intervening rows...
          (s.row - my_row).abs == (s.col - my_col).abs                     # that are an equal number of row and cols away
        end
      else
        # TODO: put in stuff to handle Ghora, Han, and leaping pieces
        return false
      end

      leap_over = dir_sym.to_s.include?('leap') ? 1 : 0
      # are all intervening spaces unoccupied?
      intervening_spaces.each do |space|
        if space.occupied?
          if leap_over <= 0
            return false
          else
            leap_over -= 1
          end
        end
      end

			# ok to move there!
			return true
		end
	end

  def in_keep?
    self.player.keep.include?(self.space)
  end

  def on_board?
    self.board.spaces.include?(self.space) && !self.in_graveyard?
  end

  def summon(col, row)
    return false if self.game.active_player != self.player

    space = self.game.board.space(col, row)
    
    if self.guard?
      if self.in_keep? && space.adjacent_to_nav?(self.player) && !space.occupied?
        self.update_attribute(:space, space)
        self.game.pass_turn
      else
        return false
      end
    else
      if self.in_keep? && space.summon_space == self.player.num && !space.occupied?
        self.update_attribute(:space, space)
        self.game.pass_turn
      else
        return false
      end
    end
  end

  def move(args = {})
    game = self.game
    return false if game.active_player != self.player || self.player.active_piece  # moving can never be done after another action, so you can only move when there is no active piece

    col = args[:col]
    row = args[:row]
    pass = args[:pass]
    puts self.game.inspect
    target_space = self.board.space(col, row)
    
    if self.can_reach?(target_space)
      # capture the occupying piece, if present
      if target_space.occupied?
        self.player.add_crystals(target_space.piece.val)
        target_space.piece.die
      end
      self.space = target_space
      self.player.update_attribute(:active_piece, self)
      if self.save
        # pass turn after a successful move
        self.game.pass_turn if pass
      else
        return false
      end
    else
      return false
    end
  end

  def flip(pass = true)
    return false if self.game.active_player != self.player || (self.player.active_piece && self.player.active_piece != self)
    flip_cost = self.val
    flip_cost = (flip_cost / 2.0).ceil if self.space.half_crystal?
    return false if self.flipped? || self.player.crystals < flip_cost

    self.player.add_crystals(-flip_cost)
    self.update_attribute(:flipped, true)
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
end
