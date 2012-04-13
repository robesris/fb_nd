class RedStone < Piece
  def grid
    RED
  end

  def move(col, row)
    if super(col, row)
      player = self.player
      player.crystals += 3
      player.save
    end
  end
end
