class Tro < Piece
  def val
    4
  end

  def side1
    [ 0, 0, 0, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0,
      0, 1, 0, 1, 0,
      0, 0, 0, 0, 0 ]
  end

  def side2
    [ 0, 0, 1, 0, 0,
      0, 1, 0, 1, 0,
      1, 0, 0, 0, 1,
      0, 1, 0, 1, 0,
      0, 0, 1, 0, 0 ]
  end

  def guard?
    true
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
