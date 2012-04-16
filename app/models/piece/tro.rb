class Tro < Piece
  def val
    4
  end

  def die
    super
    p = self.player
    p.update_attributes(:crystals => p.crystals + 10)
    puts p.game.player1.inspect
    puts p.inspect
    puts p.save!.inspect
  end
end
