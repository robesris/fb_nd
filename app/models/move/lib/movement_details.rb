class MovementDetails
  include ActiveModel::Validations
  
  attr_accessor :piece,
                :to_space,
                :direction_vector,
                :start_space

  validate do |dv|
    dv.to_space_must_be_on_board
    dv.to_space_must_be_reachable
  end

  def initialize(piece, to_space)
    self.piece = piece
    self.start_space = piece.space
    self.to_space = to_space
    self.direction_vector = DirectionVector.new(start_space, to_space)
  end

  # validations
  def to_space_must_be_on_board
    self.piece.on_board? || self.errors.add(:to_space, "is not on the board")
  end

  def to_space_must_be_reachable
    self.to_space == self.start_space && self.errors.add(:to_space, "is the same as origin space")
    direct_move_ok? || slide_move_ok? || self.errors.add(:to_space, "is not reachable")
  end


  private
  def grid
    self.piece.player.num == 1 ? self.piece.grid : self.piece.grid.reverse
  end

  # def direct_space_on_grid?
  def direct_move_ok?
    grid[
      Piece::Constants::MOVEMENT_GRID_CENTER - 
      (Piece::Constants::MOVEMENT_GRID_WIDTH * direction_vector.row_distance) + 
      direction_vector.col_distance
    ] != 0
  end

  # def direct_move_ok?

    # need this? col_move.abs <= Piece::Constants::MAX_COL_MOVE &&
		# need this? row_move.abs <= Piece::Constants::MAX_ROW_MOVE &&
    #direct_space_on_grid?
  #end

  def dir_sym
    if grid.include?(self.direction_vector.direction.leap)
      self.direction_vector.direction.leap
    elsif grid.include?(self.direction_vector.direction.normal)
      self.direction_vector.direction.normal
    else
      nil
    end
  end

  def direction_ok?
    dir_sym
  end

  def can_leap?
    dir_sym.to_s.index("leap")
  end

  def num_occupied_spaces
    direction_vector.spaces.inject(0) { |count, space| space.occupied? count && count + 1 }
  end

  def path_clear?
    num_occupied_spaces <= (can_leap? ? 1 : 0)
  end

  def slide_move_ok?
    # do we have a straight line between the two?
    self.start_space.has_line_to?(self.to_space) &&
    direction_ok? &&
    path_clear?
  end
end
