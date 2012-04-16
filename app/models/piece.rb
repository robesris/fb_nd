class Piece < ActiveRecord::Base
  attr_accessible :col, :flipped, :name, :player_id, :row, :type
  
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

  KING							= [ 0, 0, 0, 0, 0,
												0, 1, 1, 1, 0,
												0, 1, 0, 1, 0,
												0, 1, 1, 1, 0,
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

  def row
    self.space && self.space.row
  end

  def col
    self.space && self.space.col
  end

  def can_reach?(to_space)
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
			#HANDLE ADVANCED MOVEMENT
			
			# The piece's grid doesn't allow it to move there
			return false
		end
	end

  def move(args = {})
    game = self.game
    return false if game.active_player != self.player

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
      if self.save

        # pass turn after a successful move
        game.update_attribute(:active_player, game.players.reject{ |p| p.num == game.active_player.num }.first) if pass
      else
        return false
      end
    else
      return false
    end
  end

  def flip
    return false if self.flipped? || self.player.crystals < self.val

    self.player.update_attribute(:crystals, self.player.crystals - self.val)
    self.update_attribute(:flipped, true)
  end

  def die
    self.in_graveyard = true
    self.space = nil
    self.save
  end
end
