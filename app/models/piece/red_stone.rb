class RedStone < Piece::Stone
  def val
    3
  end

  def grid
    RED
  end

  def move_to(args)
    super(args)
  end
end
