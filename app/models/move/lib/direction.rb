class Direction
  # Grids should be made into their own objects to simplify this
  attr_accessor :col_distance, :row_distance, :normal, :leap

  def initialize(col_distance, row_distance)
    self.col_distance = col_distance
    self.row_distance = row_distance
    self.normal = normal_direction
    self.leap = "leap_#{normal_direction}".to_sym
  end

  
  private

  # This is an ugly placeholder until we can refactor grids
  def normal_direction
    if col_distance > 0
      if row_distance > 0
        :ur
      elsif row_distance < 0
        :dr
      else
        :rt
      end
    elsif col_distance < 0
      if row_distance > 0
        :ul
      elsif row_distance < 0
        :dl
      else
        :lt
      end
    elsif row_distance > 0
      :up
    else row_distance < 0
      :dn
    end
  end
end
