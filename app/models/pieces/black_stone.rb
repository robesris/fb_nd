class BlackStone < Piece
  def grid
    BLACK
  end

  def move(args)
    super(args)
    self.player.update_attributes(:crystals => self.player.crystals + 1)
  end
end
