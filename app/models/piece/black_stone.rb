class BlackStone < Piece::Stone
  def val
    1
  end

  def grid
    Constants::BLACK
  end

  def move_to(args)
    super(args)
  end
end
