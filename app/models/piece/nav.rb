class Piece::Nav < Piece
  def val
    60
  end

  def die
    super
    self.player.lose_game
  end
end
