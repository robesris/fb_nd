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

  #def direct_space_on_grid?
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

  def slide_move_ok?
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
  end
end