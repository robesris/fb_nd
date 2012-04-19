class Piece::Nav < Piece
  def val
    60
  end

  def side1
    KING
  end
  
  def in_check?
    self.player.in_check?
  end

  def flip
    return false if self.in_check?
    super
    self.player.win_game
  end

  def goal_over
    if self.player.empty_keep? && self.player.nav.in_last_row?
      self.player.win_game
    end 
  end

  def die
    super
    self.player.lose_game
  end
end
