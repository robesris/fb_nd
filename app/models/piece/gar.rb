class Gar < Piece
  def side2
    [ 0, 0, 0, 0, 0,
      0, 0, :leap_up, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0 ]
  end
end
