class DirectionVector
  attr_accessor :start_space, :to_space, :direction

  def initialize(start_space, to_space)
    self.start_space = start_space
    self.to_space = to_space
    self.direction = Direction.new(col_distance, row_distance)
  end

  def col_distance
    self.to_space.col - self.start_space.col
  end

  def row_distance
    self.to_space.row - self.start_space.row
  end

  def between(num1, num2)
    (num2 > num1 ? (num1 + 1)..(num2 - 1) : (num2 + 1)..(num1 - 1)).to_a
  end

  # no support for bounce movement yet
  def spaces
    intervening_cols = col_distance > 0 ? between(self.start_space.col, self.to_space.col) : between(self.to_space.col, self.start_space.col)
    intervening_rows = row_distance > 0 ? between(self.start_space.row, self.to_space.row) : between(self.to_space.row, self.start_space.row)

    self.start_space.board.spaces.select do |space|
      intervening_cols.include?(space.col) && 
      intervening_rows.include?(space.row) &&
      self.start_space.has_line_to?(space)
    end
  end
end
