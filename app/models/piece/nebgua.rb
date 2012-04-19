class Nebgua < Piece
  def side1
    [ 1, 0, 0, 0, 1,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 1, 0, 0 ]
  end

  def side2
    [ 0, 0, 0, 0, 0,
      0, :ul, 0, :ur, 0,
      0, 0, 0, 0, 0,
      0, 0, :dn, 0, 0,
      0, 0, 0, 0, 0 ]
  end

  def val
    3
  end
end
