class RedStone < Piece::Stone
  def val
    3
  end

  def grid
    RED
  end

  def move(args)
    super(args)
  end
end
