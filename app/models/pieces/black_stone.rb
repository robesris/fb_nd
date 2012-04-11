class BlackStone < Piece
  def move(col, row)
    super(col, row)
    self.player.update_attributes(:crystals => self.player.crystals + 1)
  end
end
