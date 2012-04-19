class Gar < Piece
  def val
    5
  end

  def side1
    GOLD
  end

  def side2
    [ 0, 0, 0, 0, 0,
      0, 0, :leap_up, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ]
  end
end
