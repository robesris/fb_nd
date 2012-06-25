class BlackStone < Piece::Stone
  def val
    1
  end

  def grid
    BLACK
  end

  def move(args)
    super(args)
  end
end
