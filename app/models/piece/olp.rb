class Olp < Piece
  def side1
    [ 0, 0, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 0, 0 ]
  end

  def guard?
    true
  end
end
