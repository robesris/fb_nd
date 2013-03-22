class DirectionVector
  attr_accessor :start_space, :to_space

  def initialize(start_space, to_space)
    self.start_space = start_space
    self.to_space = to_space
  end

  def col_distance
    self.to_space.col - self.start_space.col
  end

  def row_distance
    self.to_space.row - self.start_space.row
  end
end
