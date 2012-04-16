class RedStone < Piece
  def grid
    RED
  end

  def move(args)
    if super(args)
      player = self.player
      player.crystals += 3
      player.save
    end
  end
end
