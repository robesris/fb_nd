class GilTwo < Piece
  def val
    11
  end

  def side1
    [ 0, 0, 0, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0 ]
  end

  def side2
    [ 1, 0, 1, 0, 1,
      0, 1, 0, 1, 0,
      1, 1, 0, 1, 1,
      0, 1, 1, 1, 0,
      1, 0, 1, 0, 1 ]
  end
end
